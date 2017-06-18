require 'codebreaker'

class Breaker
  def initialize
    @game = Codebreaker::Game.new
    @game.start
    @game
  end

  def play(input)
    @game.compare_with(input)
  end
end
