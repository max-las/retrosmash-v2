class Console < Bridgetown::Model::Base
  def full_name
    prefix = "#{publisher} "
    prefix + name.delete_prefix(prefix)
  end

  def subtitle
    "Découvrez notre catalogue #{name}"
  end

  def relative_url
    File.join('/consoles/', slug, '/')
  end

  def breadcrumb
    {
      'Accueil' => '/',
      'Inventaire' => '/inventory/',
      name => nil
    }
  end

  def logo_path
    File.join('/images/consoles/', slug, '/logo.svg')
  end

  def logo_alt
    "logo de la #{name}"
  end

  def image_path
    File.join('/images/consoles/', slug, '/console.webp')
  end

  def image_alt
    "console #{full_name}"
  end

  def game_collection_version_path
    File.join(relative_url, '/game-collection/version.txt')
  end

  def game_collection_chunk_path(index)
    File.join(relative_url, '/game-collection/chunks/', "/#{index}.json")
  end

  def game_collection_path
    File.join(relative_url, '/game-collection/full.json')
  end
end
