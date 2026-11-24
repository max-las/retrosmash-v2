module GameConsoles
  class LetterFiltersComponent < Bridgetown::Component
    def initialize(games)
      @letters = games.map(&:letter).uniq
    end
  end
end
