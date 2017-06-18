require './lib/game'

app = Rack::Builder.new do
  use Rack::Static, :urls => ["/images", "/styles"], :root => "public"
  use Rack::Session::Cookie, :key => 'rack.session',
                             :expire_after => 216000,
                             :secret => 'change_me' # ENV['SECRET_TOKEN']
  run Game
end

run app
#use Rack::Auth::Basic, "Restricted Area" do |username, password|
#  [username, password] == ['code', 'breaker']
#end
