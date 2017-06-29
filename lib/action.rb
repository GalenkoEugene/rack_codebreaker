# frozen_string_literal: true

require 'erb'
require 'yaml'
require_relative '../model/breaker'

# Game action
class Action
  attr_accessor :game, :sid, :sessions, :request
  DUMP = 'session_store.yaml'

  def initialize(req)
    @request = req
    @request.session['init'] = true
    @sid = @request.session['session_id']
    @sessions = retrieve_sessions
    @game = sessions[sid]
    @attempts = []
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
      response.redirect('/lost') if @left.zero?
      response.redirect('/win') if result == '++++'
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

  private

  def represent(templ)
    Rack::Response.new(render(templ.to_s), templ == :not_found ? 404 : 200)
  end

  def method_missing(m_name)
    %i[index win lost not_found].include?(m_name) ? represent(m_name) : super
  end

  def prepare_data_for_view
    @score = game ? game.score : []
    @attempts = game.attempts
    @left = game.approach
  end

  def retrieve_sessions
    File.exist?(DUMP) ? YAML.load_file(DUMP) : {}
  end

  def store_game
    sessions[sid] = game
    File.open(DUMP, 'w') { |f| f.write sessions.to_yaml }
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
