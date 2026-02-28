defmodule DeltaHtml do
  @moduledoc """
  Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to HTML.

  Use `to_html/2` to render rich text for web pages and emails.
  See the [README](readme.html) for usage, feature support, and alternatives.
  """

  @link_protocol_whitelist ~w(http https mailto tel sms)
  @sanitized_link "about:blank"

  @doc """
    Convert Quill Delta to HTML.

  ## Options
    * `:preserve_whitespace` - When true, wraps the output in a div with white-space: pre-wrap to preserve whitespace. Defaults to false.
    * `:quill_css` - When true, emits Quill-style classes (for example `ql-align-*`, `ql-direction-rtl`, `ql-indent-*`) instead of inline block styles.
      Defaults to false.

  ## Examples
      iex> to_html([%{"insert" => "word\\n"}])
      "<p>word</p>"

      iex> to_html([%{"insert" => "word\\n"}], preserve_whitespace: true)
      "<div style=\\"white-space: pre-wrap;\\"><p>word</p></div>"
  """
  def to_html(delta, opts \\ []) do
    delta
    |> ops()
    |> Enum.flat_map(&split_lines/1)
    |> build_blocks(opts)
    |> maybe_preserve_whitespace(opts[:preserve_whitespace])
    |> LazyHTML.from_tree()
    |> LazyHTML.to_html()
  end

  defp ops(json) when is_binary(json), do: json |> JSON.decode!() |> ops()
  defp ops(%{"ops" => ops}), do: ops(ops)
  defp ops(ops) when is_list(ops), do: ops

  defp maybe_preserve_whitespace(html, true), do: [{"div", [{"style", "white-space: pre-wrap;"}], html}]
  defp maybe_preserve_whitespace(html, _), do: html

  defp split_lines(%{"insert" => string} = op) when is_binary(string) do
    line_end? = String.ends_with?(string, "\n")
    lines = string |> String.slice(0..if(line_end?, do: -2, else: -1)//1) |> String.split("\n")
    line_count = length(lines)

    lines
    |> Enum.with_index(1)
    |> Enum.map(fn {line, index} ->
      if index == line_count do
        Map.merge(op, %{"insert" => "#{line}#{if line_end?, do: "\n"}", "line_end?" => line_end?})
      else
        Map.merge(op, %{"insert" => "#{line}\n", "line_end?" => true})
      end
    end)
  end

  defp split_lines(op), do: [Map.put(op, "line_end?", false)]

  defp build_blocks(ops, opts, html_acc \\ [], line_acc \\ [])
  defp build_blocks([], _opts, html, []), do: reverse(html)
  defp build_blocks([], _opts, html, line), do: reverse([{"p", [], line} | html])

  defp build_blocks([%{"line_end?" => false} = op | ops], opts, html, line) do
    node = format_inline(op)
    line = if node == "", do: line, else: [node | line]
    build_blocks(ops, opts, html, line)
  end

  defp build_blocks([%{"insert" => text} = op | ops], opts, html, line) when text != "\n" do
    node = {"p", [], [op |> Map.put("insert", String.trim_trailing(text, "\n")) |> format_inline() | line]}
    build_blocks(ops, opts, [node | html], [])
  end

  # Blocks
  defp build_blocks([%{"attributes" => %{"header" => level} = attrs} | ops], opts, html, line) do
    node = {"h#{level}", line_attrs(attrs, opts), line}
    build_blocks(ops, opts, [node | html], [])
  end

  defp build_blocks([%{"attributes" => %{"blockquote" => true} = attrs} | ops], opts, html, line) do
    node = {"blockquote", line_attrs(attrs, opts), line}
    build_blocks(ops, opts, [node | html], [])
  end

  defp build_blocks([%{"attributes" => %{"list" => list_type} = attrs} | ops], opts, html, line)
       when list_type in ~w(ordered bullet checked unchecked) do
    node = {"li", list_item_attrs(attrs, opts, list_type), line}
    html = add_li(html, node, list_container_tag(list_type), attrs["indent"] || 0, list_type)
    build_blocks(ops, opts, html, [])
  end

  defp build_blocks([%{"attributes" => attrs} | ops], opts, html, line) do
    node = {"p", line_attrs(attrs, opts), line}
    build_blocks(ops, opts, [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], opts, html, []) do
    node = {"p", [], []}
    build_blocks(ops, opts, [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"}, %{"attributes" => attrs} = attr_op | ops], opts, html, line) when line != [] do
    node = {"p", line_attrs(attrs, opts), line}
    build_blocks([attr_op | ops], opts, [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], opts, html, line) do
    node = {"p", [], line}
    build_blocks(ops, opts, [node | html], [])
  end

  # Styles
  for {attr, tag} <- [underline: "u", italic: "em", bold: "strong", strike: "s", code: "code"] do
    attr = to_string(attr)

    defp format_inline(%{"attributes" => %{unquote(attr) => true}} = op) do
      {unquote(tag), [], [op |> delete_attribute(unquote(attr)) |> format_inline()]}
    end
  end

  for {attr, style} <- [color: "color", background: "background-color"] do
    attr = to_string(attr)

    defp format_inline(%{"attributes" => %{unquote(attr) => value}} = op) do
      {"span", [{"style", "#{unquote(style)}: #{value};"}], [op |> delete_attribute(unquote(attr)) |> format_inline()]}
    end
  end

  defp format_inline(%{"attributes" => %{"font" => family}} = op) when family in ~w(monospace serif) do
    {"span", [{"style", "font-family: #{family};"}], [op |> delete_attribute("font") |> format_inline()]}
  end

  defp format_inline(%{"attributes" => %{"size" => size}} = op) when size in ~w(small large huge) do
    scale =
      case size do
        "small" -> 0.75
        "large" -> 1.5
        "huge" -> 2.5
      end

    {"span", [{"style", "font-size: #{scale}em;"}], [op |> delete_attribute("size") |> format_inline()]}
  end

  defp format_inline(%{"attributes" => %{"link" => href}} = op) do
    case sanitize_link(href) do
      nil ->
        op |> delete_attribute("link") |> format_inline()

      sanitized_href ->
        {"a", [{"href", sanitized_href}, {"rel", "noopener noreferrer"}, {"target", "_blank"}],
         [op |> delete_attribute("link") |> format_inline()]}
    end
  end

  defp format_inline(%{"attributes" => %{"script" => "super"}} = op) do
    {"sup", [], [op |> delete_attribute("script") |> format_inline()]}
  end

  defp format_inline(%{"attributes" => %{"script" => "sub"}} = op) do
    {"sub", [], [op |> delete_attribute("script") |> format_inline()]}
  end

  # quill-mention
  defp format_inline(%{"insert" => %{"mention" => mention}}) do
    %{"denotationChar" => prefix, "id" => id} = mention
    "#{prefix}#{id}"
  end

  defp format_inline(%{"insert" => %{} = _unsupported_embed}), do: ""
  defp format_inline(%{"insert" => text}) when is_binary(text), do: text
  defp format_inline(%{"insert" => _unsupported}), do: ""

  defp delete_attribute(op, key) do
    case Map.delete(op["attributes"], key) do
      empty when map_size(empty) == 0 -> Map.delete(op, "attributes")
      attributes -> Map.put(op, "attributes", attributes)
    end
  end

  defp sanitize_link(""), do: nil

  defp sanitize_link(href) when is_binary(href) do
    case Regex.run(~r/^([A-Za-z][A-Za-z0-9+.-]*):/, href) do
      [_, scheme] ->
        if String.downcase(scheme) in @link_protocol_whitelist do
          href
        else
          @sanitized_link
        end

      _ -> @sanitized_link
    end
  end

  defp sanitize_link(_), do: @sanitized_link

  defp line_attrs(attrs, opts) do
    if opts[:quill_css] do
      line_class_attrs(attrs)
    else
      line_style_attrs(attrs)
    end
  end

  defp line_style_attrs(attrs) do
    styles =
      []
      |> add_line_style("text-align", attrs["align"])
      |> add_line_style("padding-left", indent_to_padding(attrs["indent"]))
      |> add_line_style("direction", direction_to_css(attrs["direction"]))
      |> Enum.reverse()

    if styles == [] do
      []
    else
      [{"style", Enum.join(styles, " ")}]
    end
  end

  defp line_class_attrs(attrs) do
    classes =
      []
      |> add_line_class(align_to_class(attrs["align"]))
      |> add_line_class(direction_to_class(attrs["direction"]))
      |> add_line_class(indent_to_class(attrs["indent"]))
      |> Enum.reverse()

    if classes == [] do
      []
    else
      [{"class", Enum.join(classes, " ")}]
    end
  end

  defp list_item_attrs(line_attrs, opts, list_type) do
    attrs =
      case list_type do
        type when type in ~w(checked unchecked) -> [{"data-list", type}]
        _ -> []
      end

    if opts[:quill_css] do
      classes =
        []
        |> add_line_class(align_to_class(line_attrs["align"]))
        |> add_line_class(direction_to_class(line_attrs["direction"]))
        |> Enum.reverse()

      case classes do
        [] -> attrs
        _ -> [{"class", Enum.join(classes, " ")} | attrs]
      end
    else
      attrs
    end
  end

  defp add_line_class(classes, nil), do: classes
  defp add_line_class(classes, ""), do: classes
  defp add_line_class(classes, class), do: [class | classes]

  defp align_to_class(align) when align in ~w(right center justify), do: "ql-align-#{align}"
  defp align_to_class(_), do: nil

  defp direction_to_class("rtl"), do: "ql-direction-rtl"
  defp direction_to_class(_), do: nil

  defp indent_to_class(indent) do
    case parse_indent(indent) do
      int when is_integer(int) and int > 0 and int <= 8 -> "ql-indent-#{int}"
      _ -> nil
    end
  end

  defp add_line_style(styles, _key, nil), do: styles
  defp add_line_style(styles, _key, ""), do: styles
  defp add_line_style(styles, key, value), do: ["#{key}: #{value};" | styles]

  defp indent_to_padding(indent) when is_integer(indent) and indent > 0, do: "#{2 * indent}em"

  defp indent_to_padding(indent) when is_binary(indent) do
    case Integer.parse(indent) do
      {parsed, ""} -> indent_to_padding(parsed)
      _ -> nil
    end
  end

  defp indent_to_padding(_), do: nil

  defp parse_indent(indent) when is_integer(indent), do: indent

  defp parse_indent(indent) when is_binary(indent) do
    case Integer.parse(indent) do
      {parsed, ""} -> parsed
      _ -> nil
    end
  end

  defp parse_indent(_), do: nil

  defp direction_to_css("rtl"), do: "rtl"
  defp direction_to_css(_), do: nil

  defp list_container_tag("ordered"), do: "ol"
  defp list_container_tag(_), do: "ul"

  # Add list item: merge into existing list when possible, else add a new top-level list.
  defp add_li(html, node, tag, indent, list_type) do
    case html do
      [{list_tag, _, _} = list | rest] when list_tag in ~w(ol ul) ->
        if indent == 0 and (list_tag != tag or list_type_of_list(list) != list_type) do
          [new_list(node, tag, 0) | html]
        else
          [merge_li(list, node, tag, indent, list_type) | rest]
        end

      _ ->
        [new_list(node, tag, indent) | html]
    end
  end

  defp new_list(node, tag, 0), do: {tag, [], [node]}

  defp new_list(node, tag, indent) when indent > 0 do
    {tag, [], [new_parent_li(node, tag, indent)]}
  end

  defp new_parent_li(node, tag, 1), do: {"li", [], [new_list(node, tag, 0)]}
  defp new_parent_li(node, tag, indent) when indent > 1, do: {"li", [], [new_list(node, tag, indent - 1)]}

  defp merge_li({tag, attrs, children} = list, node, tag, 0, list_type) do
    if list_type_of_list(list) == list_type do
      {tag, attrs, [node | children]}
    else
      {tag, attrs, [new_list(node, tag, 0) | children]}
    end
  end

  defp merge_li({list_tag, attrs, [{"li", _, _} = li | rest]}, node, tag, indent, list_type) when indent > 0 do
    {list_tag, attrs, [merge_li_into_item(li, node, tag, indent, list_type) | rest]}
  end

  defp merge_li({list_tag, attrs, children}, node, tag, indent, _list_type) when indent > 0 do
    {list_tag, attrs, [new_parent_li(node, tag, indent) | children]}
  end

  defp merge_li_into_item({"li", attrs, [{nested_tag, _, _} = nested | rest]}, node, tag, 1, list_type)
       when nested_tag in ~w(ol ul) and nested_tag == tag do
    if list_type_of_list(nested) == list_type do
      {"li", attrs, [merge_li(nested, node, tag, 0, list_type) | rest]}
    else
      {"li", attrs, [new_list(node, tag, 0), nested | rest]}
    end
  end

  defp merge_li_into_item({"li", attrs, children}, node, tag, 1, _list_type) do
    {"li", attrs, [new_list(node, tag, 0) | children]}
  end

  defp merge_li_into_item({"li", attrs, [{nested_tag, _, _} = nested | rest]}, node, tag, indent, list_type)
       when nested_tag in ~w(ol ul) and indent > 1 do
    {"li", attrs, [merge_li(nested, node, tag, indent - 1, list_type) | rest]}
  end

  defp merge_li_into_item({"li", attrs, children}, node, tag, indent, _list_type) when indent > 1 do
    {"li", attrs, [new_list(node, tag, indent - 1) | children]}
  end

  defp list_type_of_list({"ol", _, _}), do: "ordered"

  defp list_type_of_list({"ul", _, [{"li", attrs, _} | _]}) do
    case List.keyfind(attrs, "data-list", 0) do
      {_, type} when type in ~w(checked unchecked) -> type
      _ -> "bullet"
    end
  end

  defp list_type_of_list({"ul", _, _}), do: "bullet"

  # Deep reverse after processing all ops
  defp reverse(html) when is_list(html), do: html |> Enum.reverse() |> Enum.map(&reverse/1)
  defp reverse({tag, attrs, children}), do: {tag, attrs, reverse(children)}
  defp reverse(other), do: other
end
