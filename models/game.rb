class Game < Bridgetown::Model::Base
  def self.from_data(data:, console:)
    new(**data, data:, console:).tap(&:set_game_letter)
  end

  def set_game_letter
    self.game_letter = find_game_letter.tap { |game_letter| game_letter.games << self }
  end

  def to_json
    data.merge(console_slug: console.slug).to_json
  end

  private

  def find_game_letter
    first_letter = transliterated_title.chr.upcase
    console.game_letters.find { |game_letter| game_letter.letter == GameLetter.cast(first_letter) }
  end
end
