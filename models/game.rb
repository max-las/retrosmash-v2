class Game < Bridgetown::Model::Base
  LETTERS = ('A'..'Z').to_a.freeze
  SPECIAL_LETTER = '#'.freeze

  def transliterated_title
    I18n.transliterate(title)
  end

  def letter
    @letter ||= transliterated_title.chr.upcase.then do |letter|
      LETTERS.include?(letter) ? letter : SPECIAL_LETTER
    end
  end

  def cover_alt
    "converture de #{title}"
  end
end
