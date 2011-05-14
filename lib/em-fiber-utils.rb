require "fiber"
require "eventmachine"


module EventMachine
  module FiberUtils
    
    module_function
    
    def concurrent_each_with_index(enumerable, &block)
      caller_fiber = Fiber.current
      first_run = true
      exception = nil
      num_started = 0
      num_finished = 0
      begin
        enumerable.each_with_index() do |e, i|
          num_started += 1
          iter_fiber = Fiber.new() do
            begin
              yield(e, i)
            rescue Exception => ex
              exception ||= ex
            ensure
              num_finished += 1
              if !first_run && num_finished == num_started
                # Doesn't call caller_fiber.transfer() directly so that the current
                # fiber finishes completely and it doesn't leak.
                EventMachine.next_tick() do
                  caller_fiber.transfer()
                end
              end
            end
          end
          iter_fiber.resume()
        end
      ensure
        first_run = false
        if num_finished < num_started
          Fiber.yield()
        end
        raise(exception) if exception
      end
    end
    
    def concurrent_each(enumerable, &block)
      concurrent_each_with_index(enumerable) do |e, i|
        yield(e)
      end
    end
    
    def concurrent_map(enumerable, &block)
      result = []
      concurrent_each_with_index(enumerable) do |e, i|
        result[i] = yield(e)
      end
      return result
    end
    
    def call(funcs)
      concurrent_each_with_index(funcs) do |f, i|
        f.()
      end
    end
    
  end
end
