defmodule Heimdlol.SummonersSupervisor do
  @moduledoc """
    A dynamic supervisor for summoner observation
  """
  use DynamicSupervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(puuid, name, region) do
    {:ok, pid} =
      DynamicSupervisor.start_child(__MODULE__, {Summoners, {puuid, region}})

    GenServer.call(pid, :get_name)
  end
end
