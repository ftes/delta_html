defmodule DeltaHtml do
  @moduledoc """
  Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to HTML.

  This is useful to display rich text entered by users in your web UI or emails.
  It sanitizes input (prevents malicious HTML) and allows you to store only the document model (delta) and not also the HTML.

  ## Usage
  ```
  iex> delta_to_html([%{"insert" => "word\\n"}])
  "<p>word</p>"
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
  - ❌ Indent - indent
  - ✅ List - list
  - ❌ Text Alignment - align
  - ✅ Text Direction - direction
  - ✅ Code Block - code-block
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

  ## Examples
      iex> delta_to_html([%{"insert" => "word\\n"}])
      "<p>word</p>"
  """
  def delta_to_html(ops) when is_list(ops) do
    line_end? = &(is_binary(&1["insert"]) and String.ends_with?(&1["insert"], "\n"))

    ops
    |> Enum.map(&Map.put(&1, "line_end?", line_end?.(&1)))
    |> chunk()
    |> Floki.raw_html()
  end

  defp chunk(ops, html_acc \\ [], line_acc \\ [])
  defp chunk([], html, []), do: reverse(html)

  defp chunk([%{"line_end?" => false} = op | ops], html, line) do
    node = inline(op)
    chunk(ops, html, [node | line])
  end

  defp chunk([%{"insert" => text} | ops], html, line) when text != "\n" do
    node = {"p", [], [String.trim_trailing(text, "\n") | line]}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"attributes" => %{"header" => level}} | ops], html, line) do
    node = {"h#{level}", [], line}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"attributes" => %{"blockquote" => true}} | ops], html, line) do
    node = {"blockquote", [], line}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"attributes" => %{"code-block" => true}} | ops], html, line) do
    node = {"pre", [], line}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"attributes" => %{"code-block" => language}} | ops], html, line) when is_binary(language) do
    node = {"pre", [{"data-language", language}], line}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"attributes" => %{"list" => "ordered"} = attrs} | ops], html, line) do
    node = {"li", [], line}
    html = add_li(html, node, "ol", attrs["indent"] || 0)
    chunk(ops, html, [])
  end

  defp chunk([%{"attributes" => %{"list" => "bullet"} = attrs} | ops], html, line) do
    node = {"li", [], line}
    html = add_li(html, node, "ul", attrs["indent"] || 0)
    chunk(ops, html, [])
  end

  defp chunk([%{"insert" => "\n"} | ops], html, []) do
    node = {"p", [], [{"br", [], []}]}
    chunk(ops, [node | html], [])
  end

  defp chunk([%{"insert" => "\n"} | ops], html, line) do
    node = {"p", [], line}
    chunk(ops, [node | html], [])
  end

  defp inline(%{"attributes" => %{"underline" => true}} = op) do
    {"u", [], [op |> delete_attribute("underline") |> inline()]}
  end

  defp inline(%{"attributes" => %{"italic" => true}} = op) do
    {"em", [], [op |> delete_attribute("italic") |> inline()]}
  end

  defp inline(%{"attributes" => %{"bold" => true}} = op) do
    {"strong", [], [op |> delete_attribute("bold") |> inline()]}
  end

  defp inline(%{"attributes" => %{"strike" => true}} = op) do
    {"s", [], [op |> delete_attribute("strike") |> inline()]}
  end

  defp inline(%{"attributes" => %{"link" => href}} = op) do
    {"a", [{"href", href}, {"target", "_blank"}], [op |> delete_attribute("link") |> inline()]}
  end

  defp inline(%{"attributes" => %{"color" => color}} = op) do
    {"span", [{"style", "color: #{color};"}], [op |> delete_attribute("color") |> inline()]}
  end

  defp inline(%{"attributes" => %{"background" => color}} = op) do
    {"span", [{"style", "background-color: #{color};"}], [op |> delete_attribute("background") |> inline()]}
  end

  defp inline(%{"attributes" => %{"font" => "serif"}} = op) do
    {"span", [{"style", "font-family: serif;"}], [op |> delete_attribute("font") |> inline()]}
  end

  defp inline(%{"attributes" => %{"font" => "monospace"}} = op) do
    {"span", [{"style", "font-family: monospace;"}], [op |> delete_attribute("font") |> inline()]}
  end

  defp inline(%{"attributes" => %{"font" => _}} = op) do
    # Ignore unsupported font families
    op |> delete_attribute("font") |> inline()
  end

  defp inline(%{"attributes" => %{"size" => "small"}} = op) do
    {"span", [{"style", "font-size: 0.75em;"}], [op |> delete_attribute("size") |> inline()]}
  end

  defp inline(%{"attributes" => %{"size" => "large"}} = op) do
    {"span", [{"style", "font-size: 1.5em;"}], [op |> delete_attribute("size") |> inline()]}
  end

  defp inline(%{"attributes" => %{"size" => "huge"}} = op) do
    {"span", [{"style", "font-size: 2.5em;"}], [op |> delete_attribute("size") |> inline()]}
  end

  defp inline(%{"attributes" => %{"size" => _}} = op) do
    # Ignore unsupported sizes
    op |> delete_attribute("size") |> inline()
  end

  defp inline(%{"attributes" => %{"script" => "super"}} = op) do
    {"sup", [], [op |> delete_attribute("script") |> inline()]}
  end

  defp inline(%{"attributes" => %{"script" => "sub"}} = op) do
    {"sub", [], [op |> delete_attribute("script") |> inline()]}
  end

  defp inline(%{"attributes" => %{"script" => _}} = op) do
    # Ignore unsupported script values
    op |> delete_attribute("script") |> inline()
  end

  defp inline(%{"attributes" => %{"code" => true}} = op) do
    {"code", [], [op |> delete_attribute("code") |> inline()]}
  end

  defp inline(%{"insert" => %{"mention" => mention}}) do
    %{"denotationChar" => prefix, "id" => id} = mention
    "#{prefix}#{id}"
  end

  defp inline(%{"insert" => text}) when is_binary(text), do: text

  defp delete_attribute(op, key) do
    case Map.delete(op["attributes"], key) do
      empty when map_size(empty) == 0 -> Map.delete(op, "attributes")
      attributes -> Map.put(op, "attributes", attributes)
    end
  end

  defp add_li(html, node, tag, indent) do
    case html do
      [{^tag, _, _} = list | html] -> [merge_li(list, node, tag, indent) | html]
      html -> [new_list(node, tag, indent) | html]
    end
  end

  defp new_list(node, tag, 0), do: {tag, [], [node]}
  defp new_list(node, tag, indent) when indent > 0, do: {tag, [], new_list(node, tag, indent - 1)}

  defp merge_li({tag, [], children}, node, tag, 0), do: {tag, [], [node | children]}

  defp merge_li(list, node, tag, indent) when indent > 0 do
    case list do
      {^tag, [], [{^tag, _, _} = nested | rest]} ->
        {tag, [], [merge_li(nested, node, tag, indent - 0) | rest]}

      {^tag, [], rest} ->
        {tag, [], [new_list(node, tag, indent - 1) | rest]}
    end
  end

  defp reverse(html) when is_list(html), do: html |> Enum.reverse() |> Enum.map(&reverse/1)
  defp reverse({tag, attrs, children}), do: {tag, attrs, reverse(children)}
  defp reverse(other), do: other
end
