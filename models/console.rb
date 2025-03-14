class Console < Bridgetown::Model::Base
  def relative_url
    File.join('/consoles', slug, '/')
  end

  def game_letter_path(letter, page: 1)
    File.join(relative_url, Game.url_friendly_letter(letter), page.to_s, '/')
  end

  def first_game_letter_path
    game_letter_path(available_letters.first)
  end

  def logo_path
    File.join('/images/console-logos', "#{slug}.svg")
  end

  def logo_alt
    "logo de la #{title}"
  end
end
