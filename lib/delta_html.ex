defmodule DeltaHtml do
  @moduledoc """
  Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to HTML.

  This is useful to display rich text entered by users in your web UI or emails.
  It sanitizes input (prevents malicious HTML) and allows you to store only the document model (delta) and not also the HTML.

  ## Usage
  ```
  iex> DeltaHtml.to_html([%{"insert" => "word\\n"}])
  "<p>word</p>"

  # With whitespace preservation
  iex> DeltaHtml.to_html([%{"insert" => "word\\n"}], preserve_whitespace: true)
  "<div style=\\"white-space: pre-wrap;\\"><p>word</p></div>"
  ```

  ## Supported features
  ### Inline
  - ✅ Background Color - background
  - ✅ Bold - bold
  - ✅ Color - color
  - ✅ Font - font (only 'serif' and 'monospace')
  - ✅ Inline Code - code
  - ✅ Italic - italic
  - ✅ Link - link
  - ✅ Size - size (only 'small', 'large', and 'huge')
  - ✅ Strikethrough - strike
  - ✅ Superscript/Subscript - script
  - ✅ Underline - underline

  ### Block
  - ✅ Blockquote - blockquote
  - ✅ Header - header
  - ✅ Indent - indent
  - ✅ List - list
  - ✅ Text Alignment - align
  - ✅ Text Direction - direction
  - ❌ Code Block - code-block
  - ❌ Formula - formula (requires KaTeX)
  - ❌ Image - image
  - ❌ Video - video

  ### Plugins
  - ✅ quill-mention - output as `\#{denotation_char}\#{id}`, e.g. `+name`

  ## Extensibility
  Currently there are no extensions points e.g. to support further formats or plugins.
  It's a fairly short single file, so just copy and paste.

  ## Alternatives
  - Convert in browser
    - [`quill.getSemanticHTML(0)`](https://quilljs.com/docs/api#getsemantichtml)
    - Con: Need to store Delta and HTML.
    - Con: Need to sanitize HTML on server.
    - Con: Less control over output (separate transform pass on server?), especially for plugins like [quill-mention](https://github.com/quill-mention/quill-mention).
  - NIF
    - Rust: [quill-core-rs](https://github.com/mundo-68/quill-core-rs) (untested)
  - Markdown instead of Delta/Quill
    - WYSIWYG editor, e.g. [milkdown](https://milkdown.dev/)
    - HTML conversion: [earmark](https://hexdocs.pm/earmark)
  """

  @doc """
    Convert Quill Delta to HTML.

  ## Options
    * `:preserve_whitespace` - When true, wraps the output in a div with white-space: pre-wrap to preserve whitespace. Defaults to false.

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
    |> build_blocks()
    |> maybe_preserve_whitespace(opts[:preserve_whitespace])
    |> Floki.raw_html()
  end

  defp ops(json) when is_binary(json), do: json |> JSON.decode!() |> ops()
  defp ops(%{"ops" => ops}), do: ops(ops)
  defp ops(ops) when is_list(ops), do: ops

  defp maybe_preserve_whitespace(html, true), do: {"div", [{"style", "white-space: pre-wrap;"}], html}
  defp maybe_preserve_whitespace(html, _), do: html

  defp split_lines(%{"insert" => string} = op) when is_binary(string) do
    line_end? = String.ends_with?(string, "\n")
    lines = string |> String.slice(0..if(line_end?, do: -2, else: -1)//1) |> String.split("\n")

    lines
    |> Enum.with_index(1)
    |> Enum.map(fn {line, index} ->
      if index == length(lines) do
        Map.merge(op, %{"insert" => "#{line}#{if line_end?, do: "\n"}", "line_end?" => line_end?})
      else
        %{"insert" => "#{line}\n", "line_end?" => true}
      end
    end)
  end

  defp split_lines(op), do: [Map.put(op, "line_end?", false)]

  defp build_blocks(ops, html_acc \\ [], line_acc \\ [])
  defp build_blocks([], html, []), do: reverse(html)

  defp build_blocks([%{"line_end?" => false} = op | ops], html, line) do
    node = format_inline(op)
    build_blocks(ops, html, [node | line])
  end

  defp build_blocks([%{"insert" => text} | ops], html, line) when text != "\n" do
    node = {"p", [], [String.trim_trailing(text, "\n") | line]}
    build_blocks(ops, [node | html], [])
  end

  # Blocks
  defp build_blocks([%{"attributes" => %{"header" => level}} | ops], html, line) do
    node = {"h#{level}", [], line}
    build_blocks(ops, [node | html], [])
  end

  defp build_blocks([%{"attributes" => %{"blockquote" => true}} | ops], html, line) do
    node = {"blockquote", [], line}
    build_blocks(ops, [node | html], [])
  end

  defp build_blocks([%{"attributes" => %{"list" => "ordered"} = attrs} | ops], html, line) do
    node = {"li", [], line}
    html = add_li(html, node, "ol", attrs["indent"] || 0)
    build_blocks(ops, html, [])
  end

  defp build_blocks([%{"attributes" => %{"list" => "bullet"} = attrs} | ops], html, line) do
    node = {"li", [], line}
    html = add_li(html, node, "ul", attrs["indent"] || 0)
    build_blocks(ops, html, [])
  end

  defp build_blocks([%{"attributes" => %{"align" => align}} | ops], html, line) do
    node = {"p", [{"style", "text-align: #{align};"}], line}
    build_blocks(ops, [node | html], [])
  end

  defp build_blocks([%{"attributes" => %{"indent" => indent}} | ops], html, line) do
    node = {"p", [{"style", "padding-left: #{2 * indent}em;"}], line}
    build_blocks(ops, [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], html, []) do
    node = {"p", [], [{"br", [], []}]}
    build_blocks(ops, [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"}, %{"attributes" => %{"indent" => indent}} = indent_op | ops], html, line) do
    node = {"p", [{"style", "padding-left: #{2 * indent}em;"}], line}
    build_blocks([indent_op | ops], [node | html], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], html, line) do
    node = {"p", [], line}
    build_blocks(ops, [node | html], [])
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
    case URI.new(href) do
      {:ok, %URI{scheme: scheme}} when scheme in ~w(http https mailto) ->
        {"a", [{"href", href}, {"target", "_blank"}], [op |> delete_attribute("link") |> format_inline()]}

      _ ->
        op |> delete_attribute("link") |> format_inline()
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

  defp format_inline(%{"insert" => text}) when is_binary(text), do: text

  defp delete_attribute(op, key) do
    case Map.delete(op["attributes"], key) do
      empty when map_size(empty) == 0 -> Map.delete(op, "attributes")
      attributes -> Map.put(op, "attributes", attributes)
    end
  end

  # Add list item: Merge into existing list if possible, else add new list
  defp add_li(html, node, tag, indent) do
    case html do
      [{^tag, _, _} = list | html] -> [merge_li(list, node, tag, indent) | html]
      html -> [new_list(node, tag, indent) | html]
    end
  end

  defp new_list(node, tag, 0), do: {tag, [], [node]}
  defp new_list(node, tag, indent) when indent > 0, do: {tag, [], [new_list(node, tag, indent - 1)]}

  defp merge_li({tag, [], children}, node, tag, 0), do: {tag, [], [node | children]}

  defp merge_li(list, node, tag, indent) when indent > 0 do
    case list do
      {^tag, [], [{^tag, _, _} = nested | rest]} ->
        {tag, [], [merge_li(nested, node, tag, indent - 1) | rest]}

      {^tag, [], rest} ->
        {tag, [], [new_list(node, tag, indent - 1) | rest]}
    end
  end

  # Deep reverse after processing all ops
  defp reverse(html) when is_list(html), do: html |> Enum.reverse() |> Enum.map(&reverse/1)
  defp reverse({tag, attrs, children}), do: {tag, attrs, reverse(children)}
  defp reverse(other), do: other
end
