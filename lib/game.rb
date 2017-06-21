require 'erb'
require 'json'
require 'yaml'
require_relative '../controllers/breaker_controller'

class Game
  attr_accessor :game, :sid, :sessions, :score
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session["init"] = true
    @sid = @request.session['session_id']
    @sessions = retrieve_sessions
    @game = sessions[sid]
    @layout = 'layout.html.erb'.freeze
    @attempts = []
  end

  def response
    case @request.path
    when '/' then index
    when '/new_game' then new_game
    when '/try' then try
    when '/hint' then hint
    when '/win' then Rack::Response.new(render('win.html.erb'))
    when '/lost' then Rack::Response.new(render('lost.html.erb'))
    when '/score' then score
    when '/save_score' then save_score
    else Rack::Response.new(render('not_found.html.erb'))
    end
  end

  def index
    Rack::Response.new(render('index.html.erb'))
  end

  def new_game
#   @request.session['game'] = new_game
    new_game = Breaker.new(@request['user_name'] || sessions[sid]&.name)
    store(new_game)
    Rack::Response.new(render('play.html.erb'))
  end

  def try
    Rack::Response.new do |response|
#     game = @request.session['game']
      @left = game.left
      @try = @request.params['attempt']
      result = game.play(@try)
      game.to_story(@try, result)
      @attempts = game.attempts
      store(game)
      response.redirect('/win') if result == '++++'
      response.redirect('/lost') if game.left.zero?
      response.write((render('play.html.erb')))
    end
  end

  def hint
    @attempts = game.to_story('hint:', game.hint)
    store(game)
    Rack::Response.new(render('play.html.erb'))
  end

  def save_score
    game.save
    @score = game.score
    Rack::Response.new(render('score.html.erb'))
  end

  def score
    Rack::Response.new do |response|
      @score = game ? game.score : []
      response.write(render('score.html.erb'))
    end
  end

private

  def retrieve_sessions
    YAML.load_file('session_store.yaml') || Hash.new
  end

  def store(game_m)
    sessions[sid] = game_m
    File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
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
