class GameCardComponent < Bridgetown::Component
  def initialize(game:, console:)
    @game = game
    @console = console
  end
end
