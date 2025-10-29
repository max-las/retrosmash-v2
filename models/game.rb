class Game < Bridgetown::Model::Base
  def to_json(*_args)
    data.merge(console_slug: console.slug).to_json
  end

  def cover_path
    "images/consoles/#{console.slug}/games/#{slug}.webp"
  end

  def cover_alt
    "converture de #{title}"
  end
end
