# frozen_string_literal: true

require 'erb'
require 'yaml'
require_relative '../model/breaker'

# like a controller for Game
class Racker
  attr_accessor :game, :sid, :sessions, :score, :request
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session['init'] = true
    @sid = @request.session['session_id']
    @sessions = retrieve_sessions
    @game = sessions[sid]
    @attempts = []
  end

  def response
    case request.path
    when '/' then represent('index')
    when '/new_game' then new_game
    when '/try' then try
    when '/hint' then hint
    when '/score' then score
    when '/save_score' then score(:save)
    when '/win' then represent('win')
    when '/lost' then represent('lost')
    else represent('not_found')
    end
  end

  private

  def represent(template)
    Rack::Response.new(render(template))
  end

  def new_game
    @game = Breaker.new(request['user_name'] || sessions[sid]&.name)
    store_game
    represent('play')
  end

  def try
    attempt = request.params['attempt']
    result = game.play(attempt)
    game.to_story(attempt, result) && store_game
    prepare_data_for_view
    Rack::Response.new do |response|
      return response.redirect('/win') if result == '++++'
      return response.redirect('/lost') if @left.zero?
      response.write(render('play'))
    end
  end

  def hint
    game.to_story('hint:', game.hint)
    store_game
    prepare_data_for_view
    represent('play')
  end

  def score(save = false)
    game.save if save
    prepare_data_for_view
    represent('score')
  end

  def prepare_data_for_view
    @score = game ? game.score : []
    @attempts = game.attempts
    @left = game.approach
  end

  def retrieve_sessions
    YAML.load_file('session_store.yaml') || Hash.new
  end

  def store_game
    sessions[sid] = game
    File.open('session_store.yaml', 'w') { |f| f.write sessions.to_yaml }
  end

  def render(template)
    templates = [template, 'layout']
    templates.inject(nil) do |prev, temp|
      _render(temp) { prev }
    end
  end

  def _render(temp)
    path = File.expand_path("../../views/#{temp}.html.erb", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
