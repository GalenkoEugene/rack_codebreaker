# frozen_string_literal: true

require './lib/racker'

app = Rack::Builder.new do
  use Rack::Static, urls: ['/images', '/styles', '/js'], root: 'public'
  use Rack::Session::Cookie, key: 'rack.session',
                             expire_after: 216_000,
                             secret: '*&(^B234'
  run Racker
end

run app
