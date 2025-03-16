class GamePage < Bridgetown::Model::Base
  def console
    game_letter.console
  end

  def first?
    page == 1
  end

  def relative_url
    File.join(game_letter.relative_url, page.to_s, '/')
  end
end
