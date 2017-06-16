require 'erb'
require 'json'

class Game
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @layout = 'layout.html.erb'
    @attempts = []
  end

  def response
    case @request.path
    when '/' then Rack::Response.new(render('index.html.erb'))
    when '/new_game' then Rack::Response.new(render('index.html.erb'))
    when '/try' then
       Rack::Response.new do |response|
        @try = @request.params['attempt'] # need send it to 'game.compare_with()'
        #response.delete_cookie('name_of_cookie')
        response.set_cookie('story', [['1234', '+-'], ['4453', '++-'], ['4453', '++-']].to_json)
        p @attempts = JSON.parse(@request.cookies['story'])
        response.write(render('index.html.erb'))
      end
    when '/about' then Rack::Response.new(render('about.html.erb'))
    else Rack::Response.new(render('not_found.html.erb'))
    end
  end

  def render(template)
    templates = [template, @layout]
    templates.inject(nil) do | prev, temp |
      _render(temp) { prev }
    end
  end

  def _render temp
    path = File.expand_path("../../views/#{temp}", __FILE__)
    ERB.new(File.read(path)).result( binding )
  end
end
