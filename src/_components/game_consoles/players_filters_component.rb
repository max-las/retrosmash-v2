module GameConsoles
  class PlayersFiltersComponent < Bridgetown::Component
    def initialize(games)
      @players = games.map(&:players).uniq.sort
    end
  end
end
