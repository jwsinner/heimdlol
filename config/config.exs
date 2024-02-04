import Config

config :heimdlol,
       api_key: System.get_env("RIOT_KEY", "default_api_key"),
       base_uri: %URI{
         scheme: "https",
         host: "region.api.riotgames.com",
         path: "/lol/",
         port: 443
       },
       match_limit: 5

config :tesla, :adapter, {Tesla.Adapter.Finch, name: FinchMonitor}

import_config("#{config_env()}.exs")