class Console < Bridgetown::Model::Base
  GAMES_CHUNK_SIZE = 10

  def section_data
    {
      title: full_name,
      subtitle: "Découvrez notre catalogue #{name}",
      breadcrumb: {
        'Accueil' => '.',
        'Inventaire' => 'inventory/',
        name => nil
      }
    }
  end

  def full_name
    prefix = "#{publisher} "
    prefix + name.delete_prefix(prefix)
  end

  def relative_url
    File.join('consoles/', slug, '/')
  end

  def logo_path
    File.join('images/consoles/', slug, '/logo.svg')
  end

  def logo_alt
    "logo de la #{name}"
  end

  def image_path
    File.join('images/consoles/', slug, '/console.webp')
  end

  def image_alt
    "console #{full_name}"
  end

  def game_collection_metadata_path
    File.join(relative_url, '/game-collection/metadata.json')
  end

  def game_collection_chunk_path(index)
    File.join(relative_url, '/game-collection/chunks/', "#{index}.json")
  end

  def game_collection_path
    File.join(relative_url, '/game-collection/full.json')
  end
end
