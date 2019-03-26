# frozen_string_literal: true

require 'test_helper'

module Limiter
  class MixinTest < Minitest::Test
    include FakeSleep
    include AssertElapsed

    COUNT = 50
    RATE = 1
    INTERVAL = 1

    class MixinTestClass
      extend Limiter::Mixin

      limit_method :tick, rate: RATE, interval: INTERVAL

      attr_reader :ticks

      def initialize
        @ticks = 0
      end

      def tick(count = 1)
        @ticks += count
      end
    end

    def setup
      super
      @object = MixinTestClass.new
    end

    def test_method_is_rate_limited
      assert_elapsed(COUNT.to_f / RATE - 1) do
        COUNT.times do
          @object.tick
        end
      end
    end

    def test_nowait_method_raises
      Timecop.freeze do
        @object.tick
        assert_raises(WouldBlock) do
          @object.tick_nowait
        end
      end
    end

    def test_original_method_is_called
      COUNT.times do
        @object.tick
      end

      assert_equal COUNT, @object.ticks
    end

    def test_arguments_are_passed
      @object.tick 123
      assert_equal 123, @object.ticks
    end
  end
end
