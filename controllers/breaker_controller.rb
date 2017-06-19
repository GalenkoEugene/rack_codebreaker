require 'codebreaker'

class Breaker
  attr_reader :name

  def initialize(name)
    @name = name
    @game = Codebreaker::Game.new
    @game.start
    @game
  end

  def play(input)
    @game.compare_with(input)
  end
end
