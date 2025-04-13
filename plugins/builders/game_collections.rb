module Builders
  class GameCollections < SiteBuilder
    GAMES_CHUNK_SIZE = 10

    def build
      hook :site, :post_read do
        site.collections.consoles.resources.map(&:model).each do |console|
          game_collection = site.data.game_collections[console.slug]
          add_resource :pages, console.game_collection_version_path do
            content game_collection['version']
          end

          games_list = game_collection['games']
          add_resource :pages, console.game_collection_path do
            content raw games_list.to_json
          end

          games_list.each_slice(GAMES_CHUNK_SIZE).with_index do |chunk, index|
            if index.zero?
              console.first_games_chunk = chunk.map do |game_data|
                Game.new(**game_data, data: game_data, console:)
              end
            end

            add_resource :pages, console.game_collection_chunk_path(index) do
              content raw chunk.to_json
            end
          end
        end
      end
    end
  end
end
