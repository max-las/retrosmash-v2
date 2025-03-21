# This scripts has been designed for Ubuntu with imagemagick installed via `sudo apt install imagemagick`

require 'active_support'
require 'active_support/core_ext'
require 'shellwords'

CONVERTABLE_IMAGE_EXTENSIONS = %w(jpg jpeg png)

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

def expanded_children(dir)
  Dir.children(dir).map { |child| File.join(dir, child) }
end

def add_console(console_dir)
  data = parse_console_data(console_dir)
  slug = data['title'].parameterize
  create_console_resource(slug, data)
  convert_console_image(console_dir, slug)
  copy_console_logo(console_dir, slug)
  add_game_collections(console_dir, slug)
end

def parse_console_data(console_dir)
  data_file = File.join(console_dir, 'data.yml')
  raise "missing console data in #{quote(console_dir)}" unless File.file?(data_file)
    
  YAML.load_file(data_file)
end

def quote(string)
  "\"#{string}\""
end

def create_console_resource(slug, data)
  resource = File.join('future-src/_consoles', "#{slug}.html")
  make_path(resource)
  File.write(resource, "#{data.to_yaml}---")
end

def make_path(file_path)
  FileUtils.mkpath(File.dirname(file_path))
end

def convert_console_image(console_dir, console_slug)
  image = find_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if image.nil?

  output_image = File.join('future-src/images/consoles', console_slug, 'console.webp')
  make_path(output_image)
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

  output_logo = File.join('future-src/images/consoles', console_slug, 'logo.svg')
  make_path(output_logo)
  FileUtils.cp(logo, output_logo)
end

def add_game_collections(console_dir, console_slug)
  games_dir = File.join(console_dir, 'games')
  raise "missing games directory in #{quote(console_dir)}" unless File.directory?(games_dir)
  
  games = build_games_list(games_dir, console_slug)
  game_collection_path = File.join('future-src/_data/game_collections', "#{console_slug}.json")
  previous_game_collection = parse_json_file(game_collection_path)
  return if games == previous_game_collection&.fetch('games')

  game_collection = { 'version' => Time.now.to_i, 'games' => games }
  make_path(game_collection_path)
  File.write(game_collection_path, game_collection.to_json)
end

def build_games_list(games_dir, console_slug)
  games = []
  expanded_children(games_dir).each do |child|
    add_game(games, child, console_slug) if File.directory?(child)
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

  output_image = File.join('future-src/images/consoles', console_slug, 'games', "#{game_slug}.webp")
  make_path(output_image)
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def parse_json_file(file_path)
  raise "#{quote(file_path)} is a directory" if File.directory?(file_path)
  return unless File.file?(file_path)

  JSON.parse(File.read(file_path))
end

run
