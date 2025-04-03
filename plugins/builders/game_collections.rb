class Builders::GameCollections < SiteBuilder
  def build
    hook :site, :post_read do
      site.collections.consoles.resources.map(&:model_with_data).each do |console|
        game_collection = site.data.game_collections[console.slug]
        add_resource :pages, console.game_collection_version_path do
          content game_collection['version']
        end

        games_list = game_collection['games']
        add_resource :pages, console.game_collection_path do
          content raw games_list.to_json
        end

        console.initialize_game_letters
        games_list.map! { |game_data| Game.from_data(data: game_data, console:) }
        console.game_letters.each do |game_letter|
          game_letter.paginate
          game_letter.game_pages.each do |game_page|
            add_game_page_resource(game_page)
          end
        end
      end
    end
  end

  def add_game_page_resource(game_page)
    paths = [game_page.relative_url]
    if game_page.first?
      paths << game_page.game_letter.relative_url
      paths << game_page.console.relative_url if game_page.game_letter.first_available?
    end
    paths.each do |path|
      add_resource :pages, File.join(path, 'index.html') do
        layout 'game_page'
        title game_page.console.full_title
        subtitle game_page.console.subtitle
        breadcrumb game_page.console.breadcrumb
        game_page game_page
      end
    end
  end
end
