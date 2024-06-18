defmodule AbhiBlog.Repo do
  use Ecto.Repo,
    otp_app: :abhi_blog,
    adapter: Ecto.Adapters.Postgres
end
