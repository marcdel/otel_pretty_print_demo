defmodule OtelExporterStdoutPrettyTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require OpenTelemetry.Tracer, as: Tracer

  setup [:telemetry_pid_reporter]

  test "logs span with attributes" do
    Tracer.with_span "span-1" do
      Tracer.set_attribute("attr-1", "value-1")
      Tracer.set_attributes([{"attr-2", [1, 2, 3]}])
    end

    assert_receive {:span, span}
    tid = :ets.new(:my_spans, [:named_table])
    :ets.insert(:my_spans, span)

    expected_message = "[span] \"span-1\" attr-1: \"value-1\", attr-2: [1, 2, 3]"
    assert capture_log(fn -> OtelExporterStdoutPretty.export(nil, tid, nil, nil) end) =~ expected_message
  end

  def telemetry_pid_reporter(_) do
    ExUnit.CaptureLog.capture_log(fn -> :application.stop(:opentelemetry) end)

    :application.set_env(:opentelemetry, :tracer, :otel_tracer_default)

    :application.set_env(:opentelemetry, :processors, [
      {:otel_batch_processor, %{scheduled_delay_ms: 1}}
    ])

    :application.start(:opentelemetry)

    :otel_batch_processor.set_exporter(:otel_exporter_pid, self())

    :ok
  end
end