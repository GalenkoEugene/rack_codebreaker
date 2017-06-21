require 'codebreaker'

class Breaker
  attr_reader :name, :attempts, :left_hint

  def initialize(name)
    @name = name
    @attempts = []
    @left_hint = 3
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
    @left_hint-=1
    available? ? @game.hint : 'end'
  end

  def left
    @game.attempts
  end
  def save
    @game.save(name)
  end

  def score
    @game.score
  end

  private

  def available?
    true if left_hint >= 0
  end
end
