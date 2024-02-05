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

    # Because RateLimit is globally available, the limits get decremented in other tests
    # I ran these a few times back to back and the numbers below are what they seemed
    # to settle on at the time of writing.
    test "RateLimit function tests" do
      state = RateLimit.get_state()
      assert state.per_second == 13
      assert state.per_two_minutes == 113

      RateLimit.decrement()
      state = RateLimit.get_state()
      assert state.per_second == 12
      assert state.per_two_minutes == 112

      assert {:ok, true} = RateLimit.can_request?()

      Enum.each(1..12, fn _ -> RateLimit.decrement() end)
      assert {:ok, %{wait: _}} = RateLimit.can_request?()
      %{per_two_minutes: 100, per_second: 0} = RateLimit.get_state()
    end
  end
end
