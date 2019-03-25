# frozen_string_literal: true

module Limiter
  class RateQueue
    EPOCH = Time.at(0)

    attr_reader :size, :interval

    def initialize(size, interval: 60)
      @size = size
      @interval = interval

      @ring = Array.new(size, EPOCH)
      @head = 0
      @mutex = Mutex.new
    end

    def shift(wait: true)
      time = nil

      @mutex.synchronize do
        time = @ring[@head]
        sleep_interval = (time + @interval) - Time.now

        if sleep_interval.positive?
          # raise if we would sleep but the `wait` param is false
          raise WouldBlock.new(sleep_interval.to_s) unless wait

          sleep(sleep_interval)
        end

        @ring[@head] = Time.now
        @head = (@head + 1) % @size
      end

      time
    end
  end
end
