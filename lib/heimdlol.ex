defmodule Heimdlol do
  @moduledoc """
    Heimdlol (Heimdall for LoL) is a library for interacting with a very small bit the Riot Games API.
    Given a valid summoner name, we can see the players who were part of the last
    five matches that summoner played. We'll also get messages logged to the console
    when any of those summoners completes a match.
  """

  alias Heimdlol.Service.Observe

  defdelegate observe(name, region), to: Observe
end
