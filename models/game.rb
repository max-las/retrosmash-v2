class Game < Bridgetown::Model::Base
  LETTERS = ('A'..'Z').to_a.freeze
  SPECIAL_LETTER = '#'.freeze
  URL_FRIENDLY_SPECIAL_LETTER = '_'.freeze
  EXTENDED_LETTERS = [SPECIAL_LETTER, *LETTERS].freeze
  COUNT_PER_PAGE = 6.freeze

  def self.url_friendly_letter(letter)
    letter == SPECIAL_LETTER ? URL_FRIENDLY_SPECIAL_LETTER : letter
  end

  def letter  
    @letter ||= compute_letter
  end

  def cover_path
    File.join('images/games', console.slug, "#{slug}.webp")
  end

  def cover_alt
    "couverture de #{title}"
  end

  private

  def compute_letter
    first_char = transliterated_title.chr.upcase
    return first_char if LETTERS.include?(first_char)

    SPECIAL_LETTER
  end
end
