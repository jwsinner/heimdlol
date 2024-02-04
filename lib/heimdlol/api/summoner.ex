defmodule Heimdlol.Api.Summoner do
  @moduledoc """
    Functions to handle requests to the Riot Games API for summoner data
  """

  import Heimdlol.Api.Client

  @regions_upper ~w(BR1 EUN1 EUW1 JP1 KR LA1 LA2 NA1 OC1 PH2 RU SG2 TH2 TR1 TW2 VN2)
  @regions_lower Enum.map(@regions_upper, &String.downcase/1)
  @base_uri Application.get_env(:heimdlol, :base_uri)

  @spec get_by_name_and_region(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def get_by_name_and_region(name, region)
      when region in @regions_upper or
           region in @regions_lower do
    @base_uri
    |> add_region(region)
    |> URI.append_path("/summoner/v4/summoners/by-name/encoded_name")
    |> encode_name(name)
    |> client_get()
  end

  def get_by_name_and_region(_, region), do: {:error, "Invalid region: #{region}"}

  defp add_region(base_url, region) do
    host = String.replace(base_url.host, "region", String.downcase(region))
    %{base_url | host: host}
  end

  defp encode_name(base_url, name) do
    name
    |> String.downcase()
    |> URI.encode()
    |> then(&String.replace(base_url.path, "encoded_name", &1))
    |> then(&%{base_url | path: &1})
  end
end
