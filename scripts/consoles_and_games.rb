require_relative '_shared'

FILTER_GAMES_ON = %w[players letter].freeze
LETTERS = ('A'..'Z').to_a.freeze
SPECIAL_LETTER = '#'.freeze

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  expanded_children(@source_dir).each do |child|
    add_console(child) if File.directory?(child)
  end
end

def add_console(console_dir)
  data = parse_console_data(console_dir)
  enrich_console_data(data, console_dir:)
  convert_console_image(console_dir, data)
  copy_console_logo(console_dir, data)
  games = create_game_resources(console_dir, data)
  add_available_filters(data, games)
  create_console_resource(data)
end

def parse_console_data(console_dir)
  data_file = File.join(console_dir, 'data.yml')
  raise "missing console data in #{quote(console_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def enrich_console_data(data, console_dir:)
  data['layout'] = 'console'
  name, publisher = data.values_at('name', 'publisher')
  data['slug'] = name.parameterize
  data['full_name'] ||= name.include?(publisher) ? name : "#{publisher} #{name}"
  slug, full_name = data.values_at('slug', 'full_name')
  data['title'] = full_name
  data['subtitle'] = "Découvrez notre catalogue #{name}"
  data['breadcrumb'] = {
    'Accueil' => '.',
    'Inventaire' => 'inventory/',
    name => nil
  }
  logo = source_logo(console_dir)
  data['logo_path'] = "images/consoles/#{slug}/#{File.basename(logo)}"
  data['logo_alt'] = "logo de la #{name}"
  data['image_path'] = "images/consoles/#{slug}/console.webp"
  data['image_alt'] = "console #{full_name}"
end

def create_console_resource(console_data)
  resource = make_file_path('_consoles', "#{console_data['slug']}.html")
  File.write(resource, "#{console_data.to_yaml}---")
end

def convert_console_image(console_dir, console_data)
  image = find_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if image.nil?

  output_image = make_file_path(console_data['image_path'])
  convert_and_resize_image(input_path: image, output_path: output_image, height: 500, quality: 80)
end

def copy_console_logo(console_dir, console_data)
  logo = source_logo(console_dir)
  output_logo = make_file_path(console_data['logo_path'])
  FileUtils.cp(logo, output_logo)
end

def source_logo(console_dir)
  logo = File.join(console_dir, 'logo.svg')
  return logo if File.file?(logo)

  logo = File.join(console_dir, 'logo.webp')
  raise "missing console logo in #{quote(console_dir)}" unless File.file?(logo)

  logo
end

def create_game_resources(console_dir, console_data)
  games_dir = File.join(console_dir, 'games')
  unless File.directory?(games_dir)
    return [] # raise "missing games directory in #{quote(console_dir)}"
  end

  expanded_children(games_dir).filter_map do |game_dir|
    create_game_resource(game_dir, console_data['slug']) if File.directory?(game_dir)
  end
end

def create_game_resource(game_dir, console_slug)
  parse_game_data(game_dir).tap do |data|
    enrich_game_data(data, console_slug:)
    convert_game_image(game_dir, data)
    resource = make_file_path('_games', console_slug, "#{data['slug']}.html")
    File.write(resource, "#{data.to_yaml}---")
  end
end

def parse_game_data(game_dir)
  data_file = File.join(game_dir, 'data.yml')
  raise "missing game data in #{quote(game_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def enrich_game_data(data, console_slug:)
  title = data['title']
  data['slug'] = title.parameterize
  data['transliterated_title'] = I18n.transliterate(title)
  slug, transliterated_title = data.values_at('slug', 'transliterated_title')
  data['letter'] = transliterated_title.chr.upcase.then do |letter|
    LETTERS.include?(letter) ? letter : SPECIAL_LETTER
  end
  data['console'] = console_slug
  data['cover_path'] = "images/consoles/#{console_slug}/games/#{slug}.webp"
  data['cover_alt'] = "converture de #{title}"
end

def convert_game_image(game_dir, game_data)
  image = find_convertable_image(game_dir, 'cover')
  raise "missing game image in #{quote(game_dir)}" if image.nil?

  output_image = make_file_path(game_data['cover_path'])
  convert_and_resize_image(input_path: image, output_path: output_image, height: 500, quality: 80)
end

def add_available_filters(console_data, games)
  FILTER_GAMES_ON.each do |filter|
    console_data["available_#{filter}_filters"] = games.pluck(filter).uniq.sort
  end
end

run_with_context
