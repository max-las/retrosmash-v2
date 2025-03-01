class Game < Bridgetown::Model::Base
  def cover_path
    "images/games/#{console.data.slug}/#{slug}.webp"
  end

  def cover_alt
    "couverture de #{title}"
  end
end
