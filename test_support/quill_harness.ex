defmodule DeltaHtml.QuillHarness do
  @moduledoc false

  @harness_dir Path.expand("../quill_harness", __DIR__)
  @script Path.join(@harness_dir, "render.mjs")

  def available? do
    cond do
      is_nil(System.find_executable("node")) ->
        {:error, "Node.js executable not found"}

      not File.exists?(@script) ->
        {:error, "Quill harness script not found at #{@script}"}

      true ->
        case render([%{"insert" => "probe\n"}]) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def render(ops) when is_list(ops) do
    case System.find_executable("node") do
      node when is_binary(node) ->
        payload = JSON.encode!(%{"ops" => ops})

        {out, status} =
          System.cmd(node, [@script, payload],
            cd: @harness_dir,
            stderr_to_stdout: true
          )

        if status == 0 do
          {:ok, JSON.decode!(out)}
        else
          {:error, String.trim(out)}
        end

      nil ->
        {:error, "Node.js executable not found"}
    end
  rescue
    error -> {:error, Exception.message(error)}
  end
end
