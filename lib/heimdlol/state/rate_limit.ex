defmodule Heimdlol.State.RateLimit do
  @moduledoc """
    A GenServer to manage requests available to avoid rate limit issues
  """
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    schedule_per_second_reset()
    schedule_per_two_minutes_reset()

    {:ok,
     %{
       per_second: 20,
       per_two_minutes: 120,
       second_reset: DateTime.utc_now(),
       minute_reset: DateTime.utc_now()
     }}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:decrement, _from, state) do
    state
    |> Map.update(:per_second, 20, &(&1 - 1))
    |> Map.update(:per_two_minutes, 120, &(&1 - 1))
    |> then(&{:reply, &1, &1})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def decrement() do
    GenServer.call(__MODULE__, :decrement)
  end

  def can_request?() do
    state = get_state()

    cond do
      state.per_second > 0 and state.per_two_minutes > 0 ->
        {:ok, true}

      state.per_second <= 0 and state.per_two_minutes > 0 ->
        state.second_reset
        |> DateTime.add(1, :second)
        |> DateTime.diff(DateTime.utc_now(), :millisecond)
        |> then(&{:ok, %{wait: &1}})

      state[:per_two_minutes] <= 0 ->
        state.minute_reset
        |> DateTime.add(2, :minute)
        |> DateTime.diff(DateTime.utc_now(), :millisecond)
        |> then(&{:ok, %{wait: &1}})
      true -> {:error, :unknown}
    end
  end

  @impl true
  def handle_info({:reset, :per_second}, state) do
    schedule_per_second_reset()
    state
    |> Map.put(:per_second, 20)
    |> Map.put(:second_reset, DateTime.utc_now())
    |> then(&{:noreply, &1})
  end

  def handle_info({:reset, :per_two_minutes}, state) do
    schedule_per_two_minutes_reset()
    state
    |> Map.put(:per_two_minutes, 120)
    |> Map.put(:minute_reset, DateTime.utc_now())
    |> then(&{:noreply, &1})
  end

  defp schedule_per_second_reset() do
    Process.send_after(self(), {:reset, :per_second}, :timer.seconds(1))
  end

  defp schedule_per_two_minutes_reset() do
    Process.send_after(self(), {:reset, :per_two_minutes}, :timer.minutes(2))
  end
end
