defmodule Proptrackr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProptrackrWeb.Telemetry,
      Proptrackr.Repo,
      {DNSCluster, query: Application.get_env(:proptrackr, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Proptrackr.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Proptrackr.Finch},
      # Start a worker by calling: Proptrackr.Worker.start_link(arg)
      # {Proptrackr.Worker, arg},
      # Start to serve requests, typically the last entry
      ProptrackrWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proptrackr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProptrackrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
