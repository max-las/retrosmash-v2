class Builders::GameCollections < SiteBuilder
  LETTERS = ('a'..'z').to_a.freeze
  NOT_LETTER = '#'.freeze
  COUNT_PER_PAGE = 6.freeze

  def build
    hook :site, :post_read do
      site.data.game_collections.each do |console, game_collection|
        add_resource :pages, "consoles/#{console}/game-collection/version.txt" do
          content game_collection["version"]
        end
        add_resource :pages, "consoles/#{console}/game-collection/collection.json" do
          content raw game_collection["games"].to_json
        end
        group_by_letter_and_paginate(game_collection["games"]).each do |letter, paginated_games|
          paginated_games.each_with_index do |games, index|
            page = index + 1
            add_resource :pages, "consoles/#{console}/game-collection/#{letter}/#{page}.html" do
              layout 'games_page'
              page page
              games games
            end
          end
        end
      end
    end
  end

  def group_by_letter_and_paginate(games)
    games_by_letter = games.group_by { |game| letter(game) }
    games_by_letter.transform_values { |games| games.each_slice(COUNT_PER_PAGE).to_a }
  end

  def letter(game)
    formatted_first_char = I18n.transliterate(game["title"]).chr.downcase
    return formatted_first_char if LETTERS.include?(formatted_first_char)

    NOT_LETTER
  end
end
