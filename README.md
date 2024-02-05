# Heimdlol

A small observer of player's matches in League of Legends.

With a single entry point: `Heimdlol.observer/2` you will get a list of the most
recent summoners the summoner you entered has played with and against in the last 5 matches. While the list of summoners
is being built, GenServers will be started to monitor each summoner found. For one hour, each GenServer will poll the API
every minute to see if a new match has been completed, if so, it will log a message to the console.

## Setup
You can set an environment variable `RIOT_KEY` to your own Riot API key or update the default value in `config.exs`.

Run `mix deps.get` to install dependencies. Then `iex -S mix` to start the application.

## Usage
```elixir
Heimdlol.observe("summonerName", "region") # The region here is not case sensitive, so NA1 and na1 are both valid.
```

