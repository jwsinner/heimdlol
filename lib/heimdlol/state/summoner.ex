defmodule Heimdlol.State.Summoner do
  @moduledoc false
  use GenServer

  alias Heimdlol.Api.Match

  require Logger

  def start_link(summoner) do
    name = {:via, Registry, {Heimdlol.Registry, summoner.name, summoner}}
    GenServer.start_link(__MODULE__, summoner, name: name)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end

  @impl true
  def init(%{puuid: puuid, region: region} = args) do
    {:ok, [match]} = Match.get_matches(puuid, region, 1)

    args = Map.put(args, :last_match, match)
    schedule_update()
    schedule_termination()
    {:ok, args}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info(:check, %{puuid: puuid, region: region} = state) do
    case Match.get_matches(puuid, region, 1) do
      {:ok, [latest_match]} ->
        if state.last_match !== latest_match do
          Logger.info("Summoner #{state.name} completed match #{latest_match}")
        end

        new_state = %{state | last_match: latest_match}
        schedule_update()
        {:noreply, new_state}

      {:error, %{retry_after: retry_after}} ->
        Process.send_after(self(), :check, retry_after)
        {:noreply, state}
    end
  end

  def handle_info(:terminate, state) do
    {:stop, :normal, state}
  end

  defp schedule_update() do
    Process.send_after(self(), :check, :timer.minutes(1))
  end

  defp schedule_termination() do
    Process.send_after(self(), :terminate, :timer.hours(1))
  end
end
