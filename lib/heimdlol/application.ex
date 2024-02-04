defmodule Heimdlol.Application do
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

    opts = [strategy: :one_for_one, name: Heimdlol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
