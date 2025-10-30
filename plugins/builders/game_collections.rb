module Builders
  class GameCollections < SiteBuilder
    def build
      hook :site, :post_read do
        site.collections.consoles.resources.each do |console_resource|
          console = console_resource.model

          console_resource.data.merge!(console.section_data)

          game_collection = site.data.game_collections[console.slug]
          next if game_collection.blank?

          games_list = game_collection['games']
          add_resource :pages, console.game_collection_path do
            content raw games_list.to_json
          end

          console.games = games_list.map do |game_data|
            Game.new(**game_data, data: game_data, console:)
          end

          add_resource :pages, console.game_collection_version_path do
            content game_collection['version']
          end
        end
      end
    end
  end
end
