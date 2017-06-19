require 'erb'
require 'json'
require 'yaml'
require 'pry-byebug'
require_relative '../controllers/breaker_controller'

class Game
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session["init"] = true
    @layout = 'layout.html.erb'.freeze
    @attempts = []
  end

  def response
    case @request.path
    when '/' then index
    when '/new_game' then new_game
    when '/try' then try
    when '/about' then about
    when '/hint' then hint
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
#   @request.session['game'] = web_game

    sessions = YAML.load_file('session_store.yaml') || Hash.new
    web_game = Breaker.new('Petro')
    sid = @request.session['session_id']
    sessions[sid] = web_game
    File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
    Rack::Response.new(render('index.html.erb'))
  end

  def about
    Rack::Response.new(render('about.html.erb'))
  end

  def try
    Rack::Response.new do |response|
#     game = @request.session['game']
#     @try = @request.params['attempt']
#     result = game.play(@try)
#     game.to_story(@try, result)
#     @attempts = game.attempts

      sessions = YAML.load_file('session_store.yaml')
      sid = @request.session['session_id']
      game = sessions[sid]

      @try = @request.params['attempt']
      result = game.play(@try)
      game.to_story(@try, result)
      @attempts = game.attempts

      sessions[sid] = game
      File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
      response.write(render('index.html.erb'))
    end
  end

  def hint
    Rack::Response.new do |response|
      sessions = YAML.load_file('session_store.yaml')
      sid = @request.session['session_id']
      game = sessions[sid]

      @attempts = game.to_story('hint', game.hint)

      sessions[sid] = game
      File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
      response.write(render('index.html.erb'))
    end
  end
end
