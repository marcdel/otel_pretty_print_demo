defmodule OtelExporterStdoutPretty do
  @behaviour :otel_exporter

  require Logger

  @impl :otel_exporter
  def init(config) do
    {:ok, config}
  end

  @impl :otel_exporter
  def shutdown(_), do: :ok

  @impl :otel_exporter
  def export(_traces, spans_table_id, _resource, _config) do
    spans_list = :ets.tab2list(spans_table_id)

    Enum.map(spans_list, &log_pretty/1)
    :ok
  end

  def log_pretty(span) do
    {:span, _, _, [],
      :undefined, span_name, :internal, _, _,
      {:attributes, 128, :infinity, 0, attr_map},
      {:events, 128, 128, :infinity, 0, []}, {:links, 128, 128, :infinity, 0, []},
      :undefined, 1, false, :undefined} = span

    attr_string =
      attr_map
      |> Enum.map(fn {k, v} -> "#{k}: #{inspect(v)}" end)
      |> Enum.join(", ")

    Logger.debug("[span] \"#{span_name}\" #{attr_string}")
  end
end