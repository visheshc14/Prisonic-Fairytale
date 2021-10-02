defmodule Mmo.Repo do
  use Ecto.Repo,
    otp_app: :mmo,
    adapter: Ecto.Adapters.Postgres
end
