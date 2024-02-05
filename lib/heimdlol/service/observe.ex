defmodule Heimdlol.Service.Observe do
  @moduledoc false

  alias Heimdlol.Api.{Match, Summoner}
  alias Heimdlol.SummonersSupervisor

  def observe(name, region) do
    {:ok, %{"puuid" => puuid}} = Summoner.get_by_name_and_region(name, region)
    {:ok, match_ids} = Match.get_matches(puuid, region)

    match_ids
    |> Flow.from_enumerable()
    |> Flow.map(&Match.get_match(&1, region))
    |> Flow.flat_map(fn {:ok, %{"info" => %{"participants" => participants}}} ->
      participants
    end)
    |> Flow.reduce(fn -> MapSet.new() end, fn %{"puuid" => puuid, "summonerName" => name}, set ->
      MapSet.put(set, %{puuid: puuid, name: name, region: region})
    end)
    |> Enum.to_list()
    |> Enum.map(fn summoner ->
      Task.async(fn -> SummonersSupervisor.start_child(summoner) end)
      summoner.name
    end)
  end
end
