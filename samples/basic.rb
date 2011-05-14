$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")
require "em-fiber-utils"
require "em-synchrony"
require "em-synchrony/em-http"


def print_backtrace(ex, io= $stderr)
  io.printf("%s: %s (%p)\n", ex.backtrace[0], ex.message, ex.class)
  for s in ex.backtrace[1..-1]
    io.printf("        %s\n", s)
  end
end

EM.synchrony do
  begin
    
    p :begin_concurrent_each
    EM::FiberUtils.concurrent_each(1..5) do |i|
      p [:start, i]
      EM::Synchrony.sleep(i)
      p [:end, i]
    end
    p :end_concurrent_each
    
    p :begin_concurrent_map
    urls = ["http://www.google.com/", "http://www.yahoo.com/", "http://www.bing.com/"]
    reses = EM::FiberUtils.concurrent_map(urls) do |url|
      EventMachine::HttpRequest.new(url).get.response[0, 40]
    end
    p :end_concurrent_map
    p reses
    
  rescue Exception => ex
    print_backtrace(ex)
  end
  EM.stop
end
