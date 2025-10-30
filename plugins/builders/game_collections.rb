module Builders
  class GameCollections < SiteBuilder
    def build
      hook :site, :post_read do
        site.collections.consoles.resources.each do |console_resource|
          console = console_resource.model
          console_resource.data.merge!(console.section_data)
          game_collection = site.data.game_collections[console.slug]
          next if game_collection.blank?

          console.games = game_collection['games'].map do |game_data|
            Game.new(**game_data, console:)
          end
        end
      end
    end
  end
end
