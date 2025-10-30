class Console < Bridgetown::Model::Base
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
    return attributes[:full_name] if attributes[:full_name].present?
    return name if name.include?(publisher)

    "#{publisher} #{name}"
  end

  def relative_url
    File.join('consoles/', slug, '/')
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

  def game_collection_version_path
    File.join(relative_url, '/game-collection/version.txt')
  end

  def game_collection_path
    File.join(relative_url, '/game-collection/games.json')
  end
end
