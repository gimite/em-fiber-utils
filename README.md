## Usage example

Fetches 3 URLs cuncurrently using [em-synchrony](https://github.com/igrigorik/em-synchrony):

```ruby
require "em-synchrony"
require "em-synchrony/em-http"
require "em-fiber-utils"

EM.synchrony do
  urls = ["http://www.google.com/", "http://www.yahoo.com/", "http://www.bing.com/"]
  EM::FiberUtils.concurrent_each(urls) do |url|
    p EventMachine::HttpRequest.new(url).get.response
  end
  # Reaches here when we have got all responses.
  EM.stop
end
```

You can do the same thing in Sinatra + [rack-fiber_pool](https://github.com/mperham/rack-fiber_pool):

```ruby
require "sinatra"
require "em-synchrony"
require "em-synchrony/em-http"
require "rack/fiber_pool"
require "em-fiber-utils"

use(Rack::FiberPool)

get("/") do
  urls = ["http://www.google.com/", "http://www.yahoo.com/", "http://www.bing.com/"]
  EM::FiberUtils.concurrent_each(urls) do |url|
    p EventMachine::HttpRequest.new(url).get.response
  end
  # Reaches here when we have got all responses.
  return "ok"
end
```

It also provides EM::FiberUtils.concurrent_map:

```ruby
urls = ["http://www.google.com/", "http://www.yahoo.com/", "http://www.bing.com/"]
reses = EM::FiberUtils.concurrent_map(urls) do |url|
  EventMachine::HttpRequest.new(url).get.response
end
```
