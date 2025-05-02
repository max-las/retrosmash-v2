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
          games_list.each_slice(Console::GAMES_CHUNK_SIZE).with_index do |chunk, index|
            if index.zero?
              console.first_games_chunk = chunk.map do |game_data|
                Game.new(**game_data, data: game_data, console:)
              end
            end

            add_resource :pages, console.game_collection_chunk_path(index) do
              content raw chunk.to_json
            end
          end
          chunks_count = (games_list.size.to_f / Console::GAMES_CHUNK_SIZE).ceil
          add_resource :pages, console.game_collection_metadata_path do
            metadata = { version: game_collection['version'], chunks: chunks_count }
            content raw metadata.to_json
          end
        end
      end
    end
  end
end
