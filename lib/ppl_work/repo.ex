defmodule PplWork.Repo do
  use Ecto.Repo,
    otp_app: :ppl_work,
    adapter: Ecto.Adapters.Postgres
end
