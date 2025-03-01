class Builders::GameCollections < SiteBuilder
  LETTERS = ('A'..'Z').to_a.freeze
  SPECIAL_LETTER = '#'.freeze
  URL_FRIENDLY_SPECIAL_LETTER = '_'.freeze
  EXTENDED_LETTERS = [SPECIAL_LETTER, *LETTERS].freeze
  COUNT_PER_PAGE = 6.freeze

  def build
    hook :site, :post_read do
      site.collections.consoles.resources.each do |console|
        game_collection = site.data.game_collections[console.data.slug]
        add_resource :pages, "consoles/#{console.data.slug}/game-collection/version.txt" do
          content game_collection['version']
        end

        games = game_collection['games']

        add_transliterated_titles(games)
        sort(games)
        add_resource :pages, "consoles/#{console.data.slug}/game-collection/collection.json" do
          content raw games.to_json
        end

        grouped_games = group_by_letter_and_paginate(games)

        EXTENDED_LETTERS.each do |letter|
          paginated_games = grouped_games[letter]
          if paginated_games.nil?
            add_games_page_resource(console:, letter:, page: 1, games: [])
          else
            paginated_games.each_with_index do |page_games, page_index|
              add_games_page_resource(console:, letter:, page: page_index + 1, games: page_games)
            end
          end
        end
      end
    end
  end

  def add_games_page_resource(console:, letter:, page:, games:)
    path = "consoles/#{console.data.slug}/game-collection/#{url_friendly(letter)}/#{page}"
    add_resource :pages, "#{path}.html" do
      permalink "#{path}/"
      layout 'games_page'
      title console.data.title
      letter letter
      page page
      games games.map { |game| Game.new(**game, console:) }
    end
  end

  def add_transliterated_titles(games)
    games.each { |game| game['transliterated_title'] = I18n.transliterate(game['title']) }
  end

  def sort(games)
    games.sort_by! { |game| game['transliterated_title'] }
  end

  def group_by_letter_and_paginate(games)
    games_by_letter = games.group_by { |game| letter(game) }
    games_by_letter.transform_values { |games| games.each_slice(COUNT_PER_PAGE).to_a }
  end

  def letter(game)
    first_char = game['transliterated_title'].chr.upcase
    return first_char if LETTERS.include?(first_char)

    SPECIAL_LETTER
  end

  def url_friendly(letter)
    letter == SPECIAL_LETTER ? URL_FRIENDLY_SPECIAL_LETTER : letter
  end
end
