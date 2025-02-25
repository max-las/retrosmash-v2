class Builders::GameCollections < SiteBuilder
  def build
    hook :site, :post_read do
      site.data.game_collections.each do |console, game_collection|
        add_resource :game_collections, "#{console}/version.txt" do
          permalink "/game-collections/#{console}/version.txt"
          content game_collection["version"]
        end
        add_resource :game_collections, "#{console}/games.json" do
          permalink "/game-collections/#{console}/games.json"
          content raw game_collection["games"].to_json
        end
      end
    end
  end  
end
