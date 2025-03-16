class Console < Bridgetown::Model::Base
  def initialize_game_letters
    self.game_letters = GameLetter::EXTENDED_LETTERS.map do |letter|
      GameLetter.new(console: self, letter:)
    end
  end

  def relative_url
    File.join('/consoles', slug, '/')
  end

  def breadcrumb
    {
      'Accueil' => '/',
      'Inventaire' => '/inventory/',
      title => nil
    }
  end

  def first_available_game_letter
    @first_available_game_letter ||= game_letters.find(&:available?)
  end

  def logo_path
    File.join('/images/consoles', slug, 'logo.svg')
  end

  def logo_alt
    "logo de la #{title}"
  end

  def image_path
    File.join('/images/consoles', slug, 'console.webp')
  end

  def image_alt
    "console #{full_title}"
  end

  def subtitle
    "Découvrez notre catalogue #{title}"
  end
end
