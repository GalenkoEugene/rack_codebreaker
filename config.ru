require './lib/game'
use Rack::Static, :urls => ["/images", "/styles"], :root => "public"

run Game.new
