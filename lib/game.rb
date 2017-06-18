require 'erb'
require 'json'
require 'yaml'
require_relative '../controller/breaker'

class Game
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @layout = 'layout.html.erb'.freeze
    @attempts = []
  end

  def response
    case @request.path
    when '/' then index
    when '/new_game' then new_game
    when '/try' then try
    when '/about' then about
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

  def index
    Rack::Response.new(render('index.html.erb'))
  end

  def new_game
    #@request.session[:init] = true
    web_game = Breaker.new
    File.open('games.yaml', 'w') { |f| f.write ({ web_game.__id__ => web_game }.to_yaml) }
    @request.session[:game_id] = web_game.__id__
    Rack::Response.new(render('index.html.erb'))
  end

  def about
    Rack::Response.new(render('about.html.erb'))
  end

  def try
    Rack::Response.new do |response|
      game = YAML.load_file('games.yaml')[@request.session[:game_id]]
      @try = @request.params['attempt']
      game.play(@try)
      File.open('games.yaml', 'w') { |f| f.write ({ @request.session[:game_id] => game }.to_yaml) }
      #response.delete_cookie('name_of_cookie')
      #response.set_cookie('story', ['1234', '+-'].to_json)
      #p @request.session[:game_id]
      @attempts = JSON.parse(@request.cookies['story'])
      response.write(render('index.html.erb'))
    end
  end
end
