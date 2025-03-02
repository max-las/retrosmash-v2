class Console < Bridgetown::Model::Base
  def relative_url
    File.join('/consoles', slug, '/')
  end

  def letter_relative_url(letter, page: 1)
    File.join(relative_url, Game.url_friendly_letter(letter), page.to_s, '/')
  end
end
