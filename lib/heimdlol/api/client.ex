defmodule Heimdlol.Api.Client do
  @moduledoc """
   A basic client wrapper for get requests and handling responses
  """

  use Tesla, only: [:get]
  plug(Tesla.Middleware.Headers, [{"X-Riot-Token", Application.get_env(:heimdlol, :api_key)}])
  adapter(Tesla.Adapter.Finch, name: FinchMonitor)

  alias Heimdlol.State.RateLimit

  require Logger

  def client_get(%URI{} = uri) do
    case RateLimit.can_request?() do
      {:ok, true} ->
        RateLimit.decrement()

        uri
        |> URI.to_string()
        |> get()
        |> handle_response()

      {:ok, %{wait: wait}} ->
        Logger.warning("Rate limit exceeded, waiting for #{wait}ms")
        {:error, %{retry_after: wait}}

      error ->
        error
    end
  end

  @spec handle_response({:ok, Tesla.Env.t()}) :: {:ok, map()} | {:error, String.t()}
  def handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    Jason.decode(body)
  end

  def handle_response({:ok, %Tesla.Env{status: 429, headers: headers}}) do
    {"retry-after", retry_after} = List.keyfind(headers, "retry-after", 0)
    {:error, %{retry_after: String.to_integer(retry_after)}}
  end

  def handle_response({:ok, %Tesla.Env{status: status, body: body}}) do
    {:error, "#{inspect(status)} error: #{inspect(body)}"}
  end

  def handle_response({_, res}), do: {:error, "Unknown error: #{inspect(res)}"}
end
