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
    {:span,
      _, _, [], _, span_name, _, _, _,
      {:attributes, _, :infinity, _, attr_map},
      _events, _links, _, _, _, _instrumentation_scope} = span

    attr_string =
      attr_map
      |> Enum.map(fn {k, v} -> "#{k}: #{inspect(v)}" end)
      |> Enum.join(", ")

    Logger.debug("[span] \"#{span_name}\" #{attr_string}")
  end
end