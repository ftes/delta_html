defmodule DeltaHtmlQuillParityTest do
  use ExUnit.Case, async: true

  import DeltaHtml

  @moduletag :quill
  @harness_status DeltaHtml.QuillHarness.available?()

  if match?({:error, _}, @harness_status) and System.get_env("REQUIRE_QUILL_HARNESS") in ["1", "true", "TRUE"] do
    {:error, reason} = @harness_status
    raise "Quill harness is required but unavailable: #{reason}"
  end

  if match?({:error, _}, @harness_status) and System.get_env("REQUIRE_QUILL_HARNESS") not in ["1", "true", "TRUE"] do
    {:error, reason} = @harness_status
    @moduletag skip: "Quill harness unavailable: #{reason}"
  end

  @semantic_cases [
    %{
      name: "basic paragraph",
      ops: [
        %{"insert" => "word\n"}
      ]
    },
    %{
      name: "multiline formatted op",
      ops: [
        %{"attributes" => %{"bold" => true}, "insert" => "a\nb"},
        %{"insert" => "\n"}
      ]
    },
    %{
      name: "header with alignment",
      ops: [
        %{"insert" => "Heading"},
        %{"attributes" => %{"header" => 1, "align" => "center"}, "insert" => "\n"}
      ]
    },
    %{
      name: "rtl paragraph",
      ops: [
        %{"insert" => "rtl"},
        %{"attributes" => %{"direction" => "rtl"}, "insert" => "\n"}
      ]
    },
    %{
      name: "nested ordered list",
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
    }
  ]

  @roundtrip_only_cases [
    %{
      name: "list item with align and direction",
      ops: [
        %{"insert" => "rtl item"},
        %{"attributes" => %{"align" => "right", "direction" => "rtl", "list" => "bullet"}, "insert" => "\n"}
      ]
    }
  ]

  test "DeltaHtml output matches Quill semantic HTML for supported fixtures" do
    Enum.each(@semantic_cases, fn %{name: name, ops: ops} ->
      {:ok, quill} = DeltaHtml.QuillHarness.render(ops)

      expected = canonical_html(quill["semantic_html_normalized"])
      actual = canonical_html(to_html(ops))

      assert actual == expected, """
      fixture: #{name}
      quill semantic: #{quill["semantic_html"]}
      quill normalized semantic: #{expected}
      delta_html: #{actual}
      """
    end)
  end

  test "DeltaHtml output is stable after Quill normalization" do
    Enum.each(@semantic_cases ++ @roundtrip_only_cases, fn %{name: name, ops: ops} ->
      {:ok, quill} = DeltaHtml.QuillHarness.render(ops)

      original = canonical_html(to_html(ops))
      normalized = canonical_html(to_html(quill["normalized_ops"]))

      assert original == normalized, """
      fixture: #{name}
      original delta_html: #{original}
      normalized delta_html: #{normalized}
      """
    end)
  end

  defp canonical_html(html) do
    html
    |> Floki.parse_fragment!()
    |> Floki.raw_html()
    |> String.replace("\u00A0", " ")
  end
end
