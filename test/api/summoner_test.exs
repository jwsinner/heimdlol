defmodule Heimdlol.Api.SummonerTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Heimdlol.Api.Summoner

  @moduletag :capture_log

  describe "Summoner api functions" do
    test "get_by_name_and_region returns an ok tuple with summoner info" do
      Tesla.Mock.mock(fn %{method: :get} ->
        {:ok, %Tesla.Env{status: 200, body: """
        {
          "accountId": "anotherID",
          "id": "abc-123-xyz",
          "name": "TestUser",
          "profileIconId": 1,
          "puuid": "justatestpuuid1234",
          "revisionDate": 1707084287515,
          "summonerLevel": 125
        }
        """
        }}
      end)
      assert {:ok, summoner} = Summoner.get_by_name_and_region("TestUser", "na1")
      assert summoner["puuid"] == "justatestpuuid1234"
      assert summoner["accountId"] == "anotherID"
    end

    test "get_by_name_and_region returns error tuple if region not found" do
      assert {:error, "Invalid region" <> _} = Summoner.get_by_name_and_region("TestUser", "test")
    end
  end
end
