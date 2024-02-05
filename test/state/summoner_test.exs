defmodule Heimdlol.State.SummonerTest do
  use ExUnit.Case, async: true
  use Mimic

  alias Heimdlol.State.Summoner

  import ExUnit.CaptureLog
  import Tesla.Mock

  @moduletag :capture_log

  describe "Summoner GenServer functions" do
    test "Summoner has proper initializations" do
      mock_global(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: "[\"match_id\"]"}} end)

      {:ok, state} = Summoner.init(%{puuid: "test_puuid", region: "na1", name: "test_name"})
      assert state.puuid == "test_puuid"
      assert state.region == "na1"
      assert state.name == "test_name"
    end

    test "Summoner can start" do
      mock_global(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: "[\"match_id\"]"}} end)

      {:ok, pid} = Summoner.start_link(%{puuid: "test_puuid", region: "na1", name: "test_name"})
      state = GenServer.call(pid, :get_state)
      assert state.name === "test_name"
      assert state.puuid === "test_puuid"
      assert state.region === "na1"
    end

    test "Summoner logs when match updated" do
      mock_global(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: "[\"match\"]"}} end)
      {:ok, pid} = Summoner.start_link(%{puuid: "test_puuid", region: "na1", name: "test_name"})

      mock_global(fn %{method: :get} -> {:ok, %Tesla.Env{status: 200, body: "[\"match_id\"]"}} end)

      fun = fn ->
        send(pid, :check)
        :timer.sleep(250)
      end

      assert capture_log(fun) =~ "Summoner test_name completed match match_id"
    end
  end
end
