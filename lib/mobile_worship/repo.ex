defmodule MobileWorship.Repo do
  use Ecto.Repo,
    otp_app: :mobile_worship,
    adapter: Ecto.Adapters.Postgres
end
