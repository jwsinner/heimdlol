defmodule Heimdlol.Api.Match do
  @moduledoc """
   Functions to handle requests to the Riot Games API for match data
  """

  alias Heimdlol.Api.Client

  @americas ~w(BR1 LA1 LA2 NA1)
  @asia ~w(JP1 KR)
  @europe ~w(EUN1 EUW1 TR1 RU)
  @sea ~w(OC1 PH2 SG2 TH2 TW2 VN2)
  @base_uri Application.get_env(:heimdlol, :base_uri)
  @match_limit Application.get_env(:heimdlol, :match_limit)

  @spec get_matches(String.t(), String.t(), non_neg_integer()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def get_matches(account_id, region, limit \\ @match_limit) do
    @base_uri
    |> add_region(region)
    |> URI.append_path("/match/v5/matches/by-puuid/{account_id}/ids")
    |> set_account_id(account_id)
    |> URI.append_query("start=0&count=#{limit}")
    |> URI.to_string()
    |> Client.get()
    |> Client.handle_response()
  end

  @spec get_match(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def get_match(match_id, region) do
    @base_uri
    |> add_region(region)
    |> URI.append_path("/match/v5/matches/{match_id}")
    |> set_match_id(match_id)
    |> URI.to_string()
    |> Client.get()
    |> Client.handle_response()
  end

  defp add_region(base_url, region) do
    region
    |> String.upcase()
    |> get_region()
    |> case do
         {:error, _} ->
           {:error, "Invalid region: #{region}"}

         region ->
           host = String.replace(base_url.host, "region", region)
           %{base_url | host: host}
       end
  end

  defp get_region(region) do
    case region do
      region when region in @americas -> "americas"
      region when region in @asia -> "asia"
      region when region in @europe -> "europe"
      region when region in @sea -> "sea"
      _ -> {:error, "Invalid region: #{region}"}
    end
  end

  defp set_account_id(base_url, account_id) do
    path = String.replace(base_url.path, "{account_id}", account_id)
    %{base_url | path: path}
  end

  defp set_match_id(base_url, match_id) do
    path = String.replace(base_url.path, "{match_id}", match_id)
    %{base_url | path: path}
  end
end
