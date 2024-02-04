defmodule Heimdlol.Api.MatchTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Heimdlol.Api.Client
  alias Heimdlol.Api.Match

  @moduletag :capture_log

  describe "Match api functions" do
    test "get_matches returns a list of match ids" do
      Tesla.Mock.mock(fn %{method: :get} ->
        {:ok, %Tesla.Env{status: 200, body: """
          [
            "matchID-1",
            "matchID-2"
          ]
        """}}
      end)
      assert {:ok, json_body} = Match.get_matches("account_id", "na1")
      assert json_body == ["matchID-1", "matchID-2"]
    end

    test "get_match returns match details" do
      Tesla.Mock.mock(fn %{method: :get} ->
        {:ok, %Tesla.Env{status: 200, body: """
        {
          "metadata": {
            "participants": [
              "puuid-1",
              "puuid-2"
            ]
          },
          "info": {
            "gameId": "matchID-1"
          }
        }
        """}}
      end)
      assert {:ok, match} = Match.get_match("matchID-1", "na1")
      assert match["metadata"]["participants"] == ["puuid-1", "puuid-2"]
      assert match["info"]["gameId"] == "matchID-1"
    end
  end
end
