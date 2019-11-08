if Mix.env() == :bench do
  defmodule Mix.Tasks.FastSanitize.Bench do
    @moduledoc "Benchmarking task."

    use Mix.Task

    @input_dir "bench_fixtures"

    def run(_) do
      Application.ensure_all_started(:fast_html)

      inputs =
        Enum.reduce(File.ls!(@input_dir), %{}, fn input_name, acc ->
          input = File.read!(Path.join(@input_dir, input_name))
          Map.put(acc, input_name, input)
        end)

      Benchee.run(
        %{
          "FastSanitize strip tags" => fn input -> FastSanitize.strip_tags(input) end,
          "HtmlSanitizeex strip tags" => fn input -> HtmlSanitizeEx.strip_tags(input) end,
          "FastSanitize basic html" => fn input -> FastSanitize.basic_html(input) end,
          "HtmlSanitizeex basic html" => fn input -> HtmlSanitizeEx.basic_html(input) end
        },
        inputs: inputs
      )
    end
  end
end
