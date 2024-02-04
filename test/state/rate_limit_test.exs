defmodule Heimdlol.State.RateLimitTest do
  use ExUnit.Case

  alias Heimdlol.State.RateLimit

  @moduletag :capture_log

  describe "RateLimit tests" do
    test "RateLimit has proper initializations" do
      now = DateTime.utc_now()
      {:ok, state} = RateLimit.init(nil)
      assert state.per_second == 20
      assert state.per_two_minutes == 120
      assert DateTime.compare(state.second_reset, now) == :gt
      assert DateTime.compare(state.minute_reset, now) == :gt
    end

    test "RateLimit start link has proper initializations" do
      assert {:ok, pid} = RateLimit.start_link(nil)
      assert Process.alive?(pid)
      state = GenServer.call(pid, :get_state)
      assert state.per_second == 20
      assert state.per_two_minutes == 120
    end

    test "RateLimit can decrement" do
      {:ok, pid} = RateLimit.start_link(nil)
      state = GenServer.call(pid, :get_state)
      assert state.per_second == 20
      assert state.per_two_minutes == 120
      state = GenServer.call(pid, :decrement)
      assert state.per_second == 19
      assert state.per_two_minutes == 119
    end

    test "RateLimit returns true if can request" do
      assert {:ok, _pid} = RateLimit.start_link(nil)
      assert {:ok, true} = RateLimit.can_request?()
    end

    test "RateLimit returns false if too many decrements" do
      {:ok, pid} = RateLimit.start_link(nil)
      Enum.each(1..20, fn _ -> GenServer.call(pid, :decrement) end)
      assert {:ok, %{wait: _}} = RateLimit.can_request?()
      %{per_two_minutes: 100, per_second: 0} = GenServer.call(pid, :get_state)
    end
  end
end
