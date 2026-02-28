defmodule DeltaHtmlQuillParityTest do
  use ExUnit.Case, async: true

  import DeltaHtml

  @moduletag :quill
  @harness_status DeltaHtml.QuillHarness.available?()

  if match?({:error, _}, @harness_status) do
    {:error, reason} = @harness_status
    raise "Quill harness unavailable: #{reason}. Run `mix quill.setup`."
  end

  @semantic_cases [
    %{
      name: "basic paragraph",
      source: "custom baseline",
      ops: [
        %{"insert" => "word\n"}
      ]
    },
    %{
      name: "multiline formatted op",
      source: "custom baseline",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "a\nb"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "align add",
      source: "unit/formats/align.spec.ts#add",
      ops: [
        %{"insert" => "0123"},
        %{"attributes" => %{"align" => "center"}, "insert" => "\n"}
      ]
    },
    %{
      name: "color add",
      source: "unit/formats/color.spec.ts#add",
      ops: [
        %{"insert" => "0"},
        %{"attributes" => %{"color" => "red"}, "insert" => "12"},
        %{"insert" => "3\n"}
      ]
    },
    %{
      name: "header add",
      source: "unit/formats/header.spec.ts#add",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "0123"},
        %{"attributes" => %{"header" => 1}, "insert" => "\n"}
      ]
    },
    %{
      name: "header remove",
      source: "unit/formats/header.spec.ts#remove",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "0123"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "header change",
      source: "unit/formats/header.spec.ts#change",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "0123"},
        %{"attributes" => %{"header" => 2}, "insert" => "\n"}
      ]
    },
    %{
      name: "script add",
      source: "unit/formats/script.spec.ts#add",
      ops: [
        %{"insert" => "a"},
        %{"attributes" => %{"script" => "super"}, "insert" => "2"},
        %{"insert" => " + b"},
        %{"attributes" => %{"script" => "super"}, "insert" => "2"},
        %{"insert" => " = c"},
        %{"attributes" => %{"script" => "super"}, "insert" => "2"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "script replace",
      source: "unit/formats/script.spec.ts#replace",
      ops: [
        %{"insert" => "a"},
        %{"attributes" => %{"script" => "sub"}, "insert" => "2"},
        %{"insert" => " + b"},
        %{"attributes" => %{"script" => "super"}, "insert" => "2"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "header with alignment",
      source: "custom baseline",
      ops: [
        %{"insert" => "Heading"},
        %{"attributes" => %{"header" => 1, "align" => "center"}, "insert" => "\n"}
      ]
    },
    %{
      name: "rtl paragraph",
      source: "custom baseline",
      ops: [
        %{"insert" => "rtl"},
        %{"attributes" => %{"direction" => "rtl"}, "insert" => "\n"}
      ]
    },
    %{
      name: "list add",
      source: "unit/formats/list.spec.ts#add",
      ops: [
        %{"insert" => "0123\n5678"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "0123\n"}
      ]
    },
    %{
      name: "list replace",
      source: "unit/formats/list.spec.ts#replace",
      ops: [
        %{"insert" => "0123\n5678"},
        %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
        %{"insert" => "0123\n"}
      ]
    },
    %{
      name: "list format merge",
      source: "unit/formats/list.spec.ts#format merge",
      ops: [
        %{"insert" => "0123"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "5678"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "0123"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
      ]
    },
    %{
      name: "list delete merge",
      source: "unit/formats/list.spec.ts#delete merge",
      ops: [
        %{"insert" => "0123"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "0123"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
      ]
    },
    %{
      name: "nested ordered list",
      source: "custom baseline",
      ops: [
        %{"insert" => "1"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "1.1"},
        %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "2"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
      ]
    },
    %{
      name: "mixed deep lists",
      source: "custom baseline",
      ops: [
        %{"insert" => "b1"},
        %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
        %{"insert" => "b2"},
        %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
        %{"insert" => "b2.1"},
        %{"attributes" => %{"indent" => 1, "list" => "bullet"}, "insert" => "\n"},
        %{"insert" => "b2.1.1"},
        %{"attributes" => %{"indent" => 2, "list" => "bullet"}, "insert" => "\n"},
        %{"insert" => "n1.1"},
        %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "n1"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "n2"},
        %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
        %{"insert" => "n2.1.1"},
        %{"attributes" => %{"indent" => 2, "list" => "ordered"}, "insert" => "\n"}
      ]
    },
    %{
      name: "editor newline splitting",
      source: "unit/core/editor.spec.ts#insert newline splitting",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "01"},
        %{"insert" => "\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "23"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "editor multiline text",
      source: "unit/core/editor.spec.ts#insert multiline text",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "01"},
        %{"insert" => "\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "!!"},
        %{"insert" => "\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "!!"},
        %{"insert" => "\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "23"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "editor delete parts of multiple lines",
      source: "unit/core/editor.spec.ts#delete parts of multiple lines",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "0178"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "editor delete newline",
      source: "unit/core/editor.spec.ts#delete newline",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "01235678"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "editor delete multiple complete lines",
      source: "unit/core/editor.spec.ts#delete multiple complete lines",
      ops: [
        %{"attributes" => %{"italic" => true}, "insert" => "890"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "list item with align and direction",
      source: "custom fixture",
      ops: [
        %{"insert" => "rtl item"},
        %{"attributes" => %{"align" => "right", "direction" => "rtl", "list" => "bullet"}, "insert" => "\n"}
      ]
    },
    %{
      name: "link rel attribute",
      source: "unit/formats/link.spec.ts#add",
      ops: [
        %{"insert" => "0"},
        %{"attributes" => %{"link" => "https://quilljs.com"}, "insert" => "12"},
        %{"insert" => "3\n"}
      ]
    },
    %{
      name: "link sanitization",
      source: "unit/formats/link.spec.ts#add non-whitelisted protocol",
      ops: [
        %{"insert" => "0"},
        %{"attributes" => %{"link" => "about:blank"}, "insert" => "12"},
        %{"insert" => "3\n"}
      ]
    },
    %{
      name: "checklist list types",
      source: "unit/formats/list.spec.ts#checklist",
      ops: [
        %{"insert" => "0123"},
        %{"attributes" => %{"list" => "checked"}, "insert" => "\n"},
        %{"insert" => "5678"},
        %{"attributes" => %{"list" => "unchecked"}, "insert" => "\n"},
        %{"insert" => "0123\n"}
      ]
    },
    %{
      name: "list align semantics",
      source: "unit/formats/list.spec.ts#replace with attributes",
      ops: [
        %{"insert" => "0123"},
        %{"attributes" => %{"align" => "center", "list" => "bullet"}, "insert" => "\n"}
      ]
    },
    %{
      name: "empty paragraph representation",
      source: "unit/core/editor.spec.ts#insert prepend/append newline and delete entire document",
      ops: [
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "prepend newline representation",
      source: "unit/core/editor.spec.ts#insert prepend newline",
      ops: [
        %{"insert" => "\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "0123"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "append newline representation",
      source: "unit/core/editor.spec.ts#insert append newline",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "0123"},
        %{"insert" => "\n\n"}
      ]
    },
    %{
      name: "multiple newlines representation",
      source: "unit/core/editor.spec.ts#insert multiple newlines",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "01"},
        %{"insert" => "\n\n"},
        %{"attributes" => %{"bold" => true}, "insert" => "23"},
        %{"insert" => "\n"}
      ]
    }
  ]

  # These fixtures are copied from Quill tests as well, but currently differ
  # semantically because DeltaHtml intentionally/currently diverges.
  @roundtrip_only_cases [
    %{
      name: "indent class vs style",
      source: "unit/formats/indent.spec.ts#1",
      ops: [
        %{"insert" => "abc"},
        %{"attributes" => %{"indent" => 1}, "insert" => "\n"}
      ]
    }
  ]

  test "DeltaHtml output matches Quill semantic HTML for supported fixtures" do
    Enum.each(@semantic_cases, fn %{name: name, source: source, ops: ops} ->
      {:ok, quill} = DeltaHtml.QuillHarness.render(ops)

      expected = canonical_html(quill["semantic_html_normalized"])
      actual = canonical_html(to_html(ops))

      assert actual == expected, """
      fixture: #{name}
      source: #{source}
      quill semantic: #{quill["semantic_html"]}
      quill normalized semantic: #{expected}
      delta_html: #{actual}
      """
    end)
  end

  test "DeltaHtml output is stable after Quill normalization" do
    Enum.each(@semantic_cases ++ @roundtrip_only_cases, fn %{name: name, source: source, ops: ops} ->
      {:ok, quill} = DeltaHtml.QuillHarness.render(ops)

      original = canonical_html(to_html(ops))
      normalized = canonical_html(to_html(quill["normalized_ops"]))

      assert original == normalized, """
      fixture: #{name}
      source: #{source}
      original delta_html: #{original}
      normalized delta_html: #{normalized}
      """
    end)
  end

  defp canonical_html(html) do
    html
    |> LazyHTML.from_fragment()
    |> LazyHTML.to_html()
    |> String.replace("\u00A0", " ")
  end
end
