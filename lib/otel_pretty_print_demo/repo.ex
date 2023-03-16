defmodule Demo.Repo do
  use Ecto.Repo,
    otp_app: :OtelPrettyPrintDemo,
    adapter: Ecto.Adapters.Postgres
end
