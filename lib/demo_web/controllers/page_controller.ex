defmodule DemoWeb.PageController do
  use DemoWeb, :controller
  require OpenTelemetry.Tracer

  def home(conn, _params) do
    OpenTelemetry.Tracer.with_span("home") do
      OpenTelemetry.Tracer.with_span("processing") do
        render(conn, :home, layout: false)
      end
    end
  end
end
