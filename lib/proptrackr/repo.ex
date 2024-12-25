defmodule Proptrackr.Repo do
  use Ecto.Repo,
    otp_app: :proptrackr,
    adapter: Ecto.Adapters.Postgres
end
