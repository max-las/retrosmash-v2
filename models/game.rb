class Game < Bridgetown::Model::Base
  def initialize(...)
    super
    self.game_letter = find_game_letter.tap { |game_letter| game_letter.games << self }
  end

  def cover_path
    File.join('/images/consoles', console.slug, 'games', "#{slug}.webp")
  end

  def cover_alt
    "couverture de #{title}"
  end

  private

  def find_game_letter
    first_letter = transliterated_title.chr.upcase
    console.game_letters.find { |game_letter| game_letter.letter == GameLetter.cast(first_letter) }
  end
end
