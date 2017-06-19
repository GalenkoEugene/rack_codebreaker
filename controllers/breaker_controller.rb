require 'codebreaker'

class Breaker
  attr_reader :name, :attempts

  def initialize(name)
    @name = name
    @attempts = []
    @game = Codebreaker::Game.new
    @game.start
    @game
  end

  def play(input)
    @game.compare_with(input)
  end

  def to_story (amount, result)
    @attempts.push([amount, result])
  end

  def hint
    @game.hint
  end
end
