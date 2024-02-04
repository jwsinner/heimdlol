defmodule Heimdlol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Heimdlol.State.RateLimit

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: FinchMonitor},
      RateLimit,
      {Registry, keys: :unique, name: Heimdlol.Registry},
      {DynamicSupervisor, name: Heimdlol.SummonersSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Heimdlol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
