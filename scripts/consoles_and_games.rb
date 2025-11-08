require_relative '_shared'

DIRS_TO_REPLACE = %w[
  _consoles
  _games
  images/consoles
].freeze
CONSOLE_DEFAULTS = { layout: 'console' }.freeze
POSSIBLE_LOGO_FORMATS = %w[svg webp].freeze
FILTER_GAMES_ON = %w[players letter].freeze

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  create_console_defaults
  dir_children(@source_dir).each do |child|
    create_console_resource(child) if File.directory?(child)
  end
end

def create_console_defaults
  defaults_file = make_file_path('_consoles', '_defaults.yml')
  File.write(defaults_file, CONSOLE_DEFAULTS.to_yaml(stringify_names: true))
end

def create_console_resource(dir)
  data = parse_console_data(dir)
  slug = slugify(data['name'])
  games = create_game_resources(dir, slug)
  add_available_filters(data, games)
  data['image_path'] = convert_console_image(dir, slug)
  data['logo_path'] = copy_console_logo(dir, slug)
  resource = make_file_path('_consoles', "#{slug}.html")
  File.write(resource, "#{data.to_yaml}---")
end

def parse_console_data(console_dir)
  data_file = File.join(console_dir, 'data.yml')
  raise "missing console data in #{quote(console_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def create_game_resources(console_dir, console_slug)
  games_dir = File.join(console_dir, 'games')
  unless File.directory?(games_dir)
    return [] # TODO: raise "missing games directory in #{quote(console_dir)}"
  end

  create_game_defaults(console_slug)
  dir_children(games_dir).filter_map do |game_dir|
    create_game_resource(console_slug, game_dir) if File.directory?(game_dir)
  end
end

def create_game_defaults(console_slug)
  defaults = { console: console_slug }
  defaults_file = make_file_path('_games', console_slug, '_defaults.yml')
  File.write(defaults_file, defaults.to_yaml(stringify_names: true))
end

def create_game_resource(console_slug, dir)
  data = parse_game_data(dir)
  slug = slugify(data['title'])
  data['cover_path'] = convert_game_image(console_slug, dir, slug)
  resource = make_file_path('_games', console_slug, "#{slug}.html")
  File.write(resource, "#{data.to_yaml}---")
  Game.new(**data)
end

def parse_game_data(game_dir)
  data_file = File.join(game_dir, 'data.yml')
  raise "missing game data in #{quote(game_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def convert_game_image(console_slug, game_dir, game_slug)
  input_image = find_convertable_image(game_dir, 'cover')
  raise "missing game image in #{quote(game_dir)}" if input_image.nil?

  relative_path = "images/consoles/#{console_slug}/games/#{game_slug}.webp"
  output_image = make_file_path(relative_path)
  convert_and_resize_image(input_path: input_image, output_path: output_image, height: 500, quality: 80)
  relative_path
end

def add_available_filters(console_data, games)
  FILTER_GAMES_ON.each do |filter|
    console_data["available_#{filter}_filters"] = games.map { it.public_send(filter) }.uniq.sort
  end
end

def convert_console_image(console_dir, console_slug)
  input_image = find_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if input_image.nil?

  relative_path = "images/consoles/#{console_slug}/console.webp"
  output_image = make_file_path(relative_path)
  convert_and_resize_image(input_path: input_image, output_path: output_image, height: 500, quality: 80)
  relative_path
end

def copy_console_logo(console_dir, console_slug)
  input_logo = input_logo(console_dir)
  relative_path = "images/consoles/#{console_slug}/#{File.basename(input_logo)}"
  output_logo = make_file_path(relative_path)
  FileUtils.cp(input_logo, output_logo)
  relative_path
end

def input_logo(console_dir)
  POSSIBLE_LOGO_FORMATS.each do |format|
    candidate = File.join(console_dir, "logo.#{format}")
    return candidate if File.file?(candidate)
  end

  raise "missing console logo in #{quote(console_dir)}"
end

run_with_context
