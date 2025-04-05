# This scripts has been designed for Ubuntu with imagemagick installed via `sudo apt install imagemagick`

require 'active_support'
require 'active_support/core_ext'
require 'shellwords'

CONVERTABLE_IMAGE_EXTENSIONS = %w(jpg jpeg png)
OUTPUT_DIR = 'src'
CONSTRUCTION_DIR = File.join('under_construction', OUTPUT_DIR)
FILTER_GAMES_ON = %w(players)

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  FileUtils.remove_entry(CONSTRUCTION_DIR) if File.exist?(CONSTRUCTION_DIR)
  expanded_children(@source_dir).each do |child|
    add_console(child) if File.directory?(child)
  end
  FileUtils.copy_entry(CONSTRUCTION_DIR, 'src')
  FileUtils.remove_dir(CONSTRUCTION_DIR)
end

def expanded_children(dir)
  Dir.children(dir).map { |child| File.join(dir, child) }
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

def quote(string)
  "\"#{string}\""
end

def create_console_resource(console_data)
  resource = make_file_path('_consoles', "#{console_data['slug']}.html")
  File.write(resource, "#{console_data.to_yaml}---")
end

def make_file_path(*segments)
  File.join(CONSTRUCTION_DIR, *segments).tap do |output_path|
    FileUtils.mkpath(File.dirname(output_path))
  end
end

def convert_console_image(console_dir, console_slug)
  image = find_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if image.nil?

  output_image = make_file_path('images/consoles', console_slug, 'console.webp')
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def find_convertable_image(dir, filename)
  CONVERTABLE_IMAGE_EXTENSIONS.each do |extension|
    candidate = File.join(dir, "#{filename}.#{extension}")
    return candidate if File.file?(candidate)
  end
  nil
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
  game_collection_path = File.join('_data/game_collections', "#{console_data['slug']}.json")
  previous_game_collection = parse_json_file(File.join(OUTPUT_DIR, game_collection_path))
  return if games == previous_game_collection&.fetch('games')

  game_collection = { 'version' => Time.now.to_i, 'games' => games }
  output_game_collection_path = make_file_path(game_collection_path)
  File.write(output_game_collection_path, game_collection.to_json)
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
  games << data
  convert_game_image(game_dir, data['slug'], console_slug)
end

def parse_game_data(game_dir)
  data_file = File.join(game_dir, 'data.yml')
  raise "missing game data in #{quote(game_dir)}" unless File.file?(data_file)

  data = YAML.load_file(data_file)
  data.merge!(
    'slug' => data['title'].parameterize,
    'transliterated_title' => I18n.transliterate(data['title'])
  )
end

def convert_game_image(game_dir, game_slug, console_slug)
  image = find_convertable_image(game_dir, 'cover')
  raise "missing game image in #{quote(game_dir)}" if image.nil?

  output_image = make_file_path('images/consoles', console_slug, 'games', "#{game_slug}.webp")
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def parse_json_file(file_path)
  raise "#{quote(file_path)} is a directory" if File.directory?(file_path)
  return unless File.file?(file_path)

  JSON.parse(File.read(file_path))
end

run
