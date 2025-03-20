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
  convert_console_image(console_dir, slug)
  copy_console_logo(console_dir, slug)
  unless File.directory?(File.join(console_dir, 'games'))
    raise "missing games directory in #{quote(console_dir)}" 
  end
end

def parse_console_data(console_dir)
  data_file = File.join(console_dir, 'data.yml')
  raise "missing console data in #{quote(console_dir)}" unless File.file?(data_file)
    
  YAML.load_file(data_file)
end

def quote(string)
  "\"#{string}\""
end

def convert_console_image(console_dir, console_slug)
  image = get_convertable_image(console_dir, 'console')
  raise "missing console image in #{quote(console_dir)}" if image.nil?

  output_image = File.join('future-src/images/consoles', console_slug, 'console.webp')
  FileUtils.mkpath(File.dirname(output_image))
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def get_convertable_image(dir, filename)
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
  FileUtils.mkpath(File.dirname(output_logo))
  FileUtils.cp(logo, output_logo)
end

run
