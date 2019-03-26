# frozen_string_literal: true

module Limiter
  module Mixin
    def limit_method(method, rate:, interval: 60)
      queue = RateQueue.new(rate, interval: interval)

      mixin = Module.new do
        define_method(method) do |*args|
          queue.shift
          super(*args)
        end

        define_method("#{method}_nowait".to_sym) do |*args|
          queue.shift(wait: false)
          super(*args)
        end
      end

      prepend mixin
    end
  end
end
