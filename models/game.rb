class Game < Bridgetown::Model::Base
  LETTERS = ('A'..'Z').to_a.freeze
  SPECIAL_LETTER = '#'.freeze

  def transliterated_title
    @transliterated_title ||= I18n.transliterate(title)
  end

  def sort_key
    if transliterated_title.match?(/ \d\z/)
      transliterated_title
    else
      "#{transliterated_title} 0"
    end
  end

  def letter
    @letter ||= transliterated_title.chr.upcase.then do |letter|
      LETTERS.include?(letter) ? letter : SPECIAL_LETTER
    end
  end

  def cover_alt
    "converture de #{title}"
  end

  def pegi?
    attributes.key?('pegi')
  end
end
