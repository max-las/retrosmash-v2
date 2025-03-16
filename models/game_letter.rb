class GameLetter < Bridgetown::Model::Base
  LETTERS = ('A'..'Z').to_a.freeze
  SPECIAL_LETTER = '#'.freeze
  URL_FRIENDLY_SPECIAL_LETTER = '_'.freeze
  EXTENDED_LETTERS = [SPECIAL_LETTER, *LETTERS].freeze
  GAMES_PER_PAGE = 6.freeze

  def self.cast(letter)
    LETTERS.include?(letter) ? letter : SPECIAL_LETTER
  end

  def initialize(...)
    super
    self.games = []
  end

  def paginate
    self.game_pages = []
    games.each_slice(GAMES_PER_PAGE).map.with_index do |games_group, index|
      game_pages << GamePage.new(page: index + 1, game_letter: self, games: games_group)
    end
  end

  def relative_url
    File.join(console.relative_url, url_friendly_letter, '/')
  end

  def available?
    game_pages.any?
  end

  def first_available?
    self == console.first_available_game_letter
  end

  private

  def url_friendly_letter
    letter == SPECIAL_LETTER ? URL_FRIENDLY_SPECIAL_LETTER : letter
  end
end
