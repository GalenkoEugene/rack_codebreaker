# frozen_string_literal: true

require_relative './action'

# like a controller for Game
class Racker
  attr_reader :go_to, :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @go_to = Action.new(@request)
  end

  def response
    case request.path
    when '/' then go_to.index
    when '/new_game' then go_to.new_game
    when '/try' then go_to.try
    when '/hint' then go_to.hint
    when '/score' then go_to.score
    when '/save_score' then go_to.score(:save)
    when '/win' then go_to.win
    when '/lost' then go_to.lost
    else go_to.not_found
    end
  end
end
