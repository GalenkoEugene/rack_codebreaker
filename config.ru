require './lib/game'

app = Rack::Builder.new do
  use Rack::Static, :urls => ["/images", "/styles"], :root => "public"
  run Game
end

run app
#use Rack::Auth::Basic, "Restricted Area" do |username, password|
#  [username, password] == ['code', 'breaker']
#end
