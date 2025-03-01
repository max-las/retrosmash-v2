class Builders::GameCollections < SiteBuilder
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

        games.map! { |game| Game.new(**game, console:) }

        grouped_games = group_by_letter_and_paginate(games)
        console.data.available_letters = grouped_games.keys
        grouped_games.each do |letter, paginated_games|
          paginated_games.each_with_index do |page_games, page_index|
            add_games_page_resource(
              console:,
              letter:,
              page: page_index + 1,
              games: page_games
            )
          end
        end
      end
    end
  end

  def add_games_page_resource(console:, letter:, page:, games:)
    paths = [console.letter_relative_url(letter, page:)]
    paths << console.relative_url if page == 1 && letter == console.data.available_letters.first
    paths.each do |path|
      add_resource :pages, File.join(path, 'index.html') do
        layout 'console_and_games'
        title console.data.title
        console console
        letter letter
        page page
        games games.map { |game| Game.new(**game, console:) }
      end
    end
  end

  def add_transliterated_titles(games_data)
    games_data.each { |game| game['transliterated_title'] = I18n.transliterate(game['title']) }
  end

  def sort(games_data)
    games_data.sort_by! { |game| game['transliterated_title'] }
  end

  def group_by_letter_and_paginate(games)
    games.group_by(&:letter).transform_values do |letter_games|
      letter_games.each_slice(Game::COUNT_PER_PAGE).to_a
    end
  end
end
