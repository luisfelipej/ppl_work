defmodule PplWork.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PplWorkWeb.Telemetry,
      PplWork.Repo,
      {DNSCluster, query: Application.get_env(:ppl_work, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PplWork.PubSub},
      PplWorkWeb.Presence,
      # Start a worker by calling: PplWork.Worker.start_link(arg)
      # {PplWork.Worker, arg},
      # Start to serve requests, typically the last entry
      PplWorkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PplWork.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PplWorkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
