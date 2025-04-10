# This scripts has been designed for Ubuntu with imagemagick installed via `sudo apt install imagemagick`

require_relative '_shared'

FILTER_GAMES_ON = %w[players letter].freeze
LETTERS = ('A'..'Z').to_a.freeze
SPECIAL_LETTER = '#'.freeze

def run
  expanded_children(@source_dir).each do |child|
    add_console(child) if File.directory?(child)
  end
end

def add_console(console_dir)
  data = parse_console_data(console_dir)
  data['slug'] = data['title'].parameterize
  convert_console_image(console_dir, data['slug'])
  copy_console_logo(console_dir, data['slug'])
  add_game_collection(console_dir, data)
  create_console_resource(data)
end

def parse_console_data(console_dir)
  data_file = File.join(console_dir, 'data.yml')
  raise "missing console data in #{quote(console_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def create_console_resource(console_data)
  resource = make_file_path('_consoles', "#{console_data['slug']}.html")
  File.write(resource, "#{console_data.to_yaml}---")
end

def convert_console_image(console_dir, console_slug)
  image = find_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if image.nil?

  output_image = make_file_path('images/consoles', console_slug, 'console.webp')
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def copy_console_logo(console_dir, console_slug)
  logo = File.join(console_dir, 'logo.svg')
  raise "missing console logo in #{quote(console_dir)}" unless File.file?(logo)

  output_logo = make_file_path('images/consoles', console_slug, 'logo.svg')
  FileUtils.cp(logo, output_logo)
end

def add_game_collection(console_dir, console_data)
  games_dir = File.join(console_dir, 'games')
  raise "missing games directory in #{quote(console_dir)}" unless File.directory?(games_dir)

  games = build_games_list(games_dir, console_data)
  game_collection_path = File.join('_data/game_collections', "#{console_data['slug']}.yml")
  previous_game_collection = parse_potential_yaml_file(File.join(OUTPUT_DIR, game_collection_path))
  return if games == previous_game_collection&.fetch('games')

  game_collection = { 'version' => Time.now.to_i, 'games' => games }
  output_game_collection_path = make_file_path(game_collection_path)
  File.write(output_game_collection_path, game_collection.to_yaml)
end

def build_games_list(games_dir, console_data)
  games = []
  expanded_children(games_dir).each do |child|
    add_game(games, child, console_data['slug']) if File.directory?(child)
  end
  FILTER_GAMES_ON.each do |filter|
    console_data["available_#{filter}_filters"] = games.pluck(filter).uniq.sort
  end
  games.sort_by! { |game| game['transliterated_title'] }
end

def add_game(games, game_dir, console_slug)
  data = parse_game_data(game_dir)
  enrich_game_data(data)
  games << data
  convert_game_image(game_dir, data['slug'], console_slug)
end

def parse_game_data(game_dir)
  data_file = File.join(game_dir, 'data.yml')
  raise "missing game data in #{quote(game_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def enrich_game_data(data)
  data['slug'] = data['title'].parameterize
  data['transliterated_title'] = I18n.transliterate(data['title'])
  data['letter'] = data['transliterated_title'].chr.upcase.then do |letter|
    LETTERS.include?(letter) ? letter : SPECIAL_LETTER
  end
end

def convert_game_image(game_dir, game_slug, console_slug)
  image = find_convertable_image(game_dir, 'cover')
  raise "missing game image in #{quote(game_dir)}" if image.nil?

  output_image = make_file_path('images/consoles', console_slug, 'games', "#{game_slug}.webp")
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def parse_potential_yaml_file(file_path)
  raise "#{quote(file_path)} is a directory" if File.directory?(file_path)
  return unless File.file?(file_path)

  YAML.load_file(file_path)
end

run_with_context
