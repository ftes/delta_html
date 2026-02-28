defmodule Mix.Tasks.Quill.Setup do
  @shortdoc "Install or verify Quill harness dependencies"

  @moduledoc """
  Installs or verifies Node dependencies used by the Quill parity harness.

      mix quill.setup
      mix quill.setup --check

  `--check` validates that harness dependencies are present without installing.
  """

  use Mix.Task

  @switches [check: :boolean]

  @impl Mix.Task
  def run(args) do
    {opts, _argv, invalid} = OptionParser.parse(args, strict: @switches)

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    npm = System.find_executable("npm") || Mix.raise("npm was not found in PATH")

    harness_dir = Path.expand("quill_harness", File.cwd!())
    package_json = Path.join(harness_dir, "package.json")
    lockfile = Path.join(harness_dir, "package-lock.json")
    node_modules = Path.join(harness_dir, "node_modules")

    if !File.exists?(package_json) do
      Mix.raise("Quill harness package.json not found at #{package_json}")
    end

    if opts[:check] do
      if !File.exists?(lockfile) do
        Mix.raise("Quill harness lockfile is missing at #{lockfile}. Run `mix quill.setup`.")
      end

      if !File.dir?(node_modules) do
        Mix.raise("Quill harness dependencies are missing. Run `mix quill.setup`.")
      end

      run_cmd(npm, ["ls", "--prefix", harness_dir, "--depth=0"])
      Mix.shell().info("Quill harness dependencies are ready")
    else
      run_cmd(npm, ["ci", "--prefix", harness_dir])
      Mix.shell().info("Quill harness dependencies installed")
    end
  end

  defp run_cmd(cmd, args) do
    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {output, 0} ->
        if String.trim(output) != "", do: Mix.shell().info(output)

      {output, status} ->
        message = String.trim(output)

        Mix.raise(if(message == "", do: "Command failed with status #{status}", else: message))
    end
  end
end
