class Game < Bridgetown::Model::Base
  def cover_path
    "images/consoles/#{console.slug}/games/#{slug}.webp"
  end

  def cover_alt
    "converture de #{title}"
  end
end
