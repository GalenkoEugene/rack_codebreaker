require 'erb'
require 'json'
require 'yaml'
require 'pry-byebug'
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
    sessions = YAML.load_file('games.yaml') || Hash.new
    web_game = Breaker.new('Petro')
    sid = @request.session['session_id']
    sessions[sid] = web_game
    File.open('games.yaml', 'w') { |f| f.write sessions.to_yaml }
    Rack::Response.new(render('index.html.erb'))
  end

  def about
    Rack::Response.new(render('about.html.erb'))
  end

  def try
    Rack::Response.new do |response|
      sessions = YAML.load_file('games.yaml')
      sid = @request.session['session_id']
      game = sessions[sid]
      @try = @request.params['attempt']
      game.play(@try)
      sessions[sid] = game
      File.open('games.yaml', 'w') { |f| f.write sessions.to_yaml }
      response.write(render('index.html.erb'))
    end
  end
end
