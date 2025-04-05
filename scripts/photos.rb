# This scripts has been designed for Ubuntu with imagemagick installed via `sudo apt install imagemagick`

require_relative '_shared.rb'

def run
  expanded_children(@source_dir).each do |child|
    add_photo_event(child) if File.directory?(child)
  end
end

def add_photo_event(event_dir)
  data = parse_photo_event_data(event_dir)
  data['slug'] = data['title'].parameterize
  data['layout'] = 'photo_event'
  data['section_title'] = 'Galerie photo'
  data['breadcrumb'] = {
    'Accueil' => '/',
    'Galerie photo' => '/gallery/',
    data['title'] => nil
  }
  convert_event_logo(event_dir, data['slug'])
  add_photos(event_dir, data)
  create_photo_event_resource(data)
end

def parse_photo_event_data(event_dir)
  data_file = File.join(event_dir, 'data.yml')
  raise "missing event data in #{quote(event_dir)}" unless File.file?(data_file)
    
  YAML.load_file(data_file)
end

def create_photo_event_resource(data)
  resource = make_file_path('_photo_events', "#{data['slug']}.html")
  File.write(resource, "#{data.to_yaml}---")
end

def convert_event_logo(event_dir, event_slug)
  image = find_convertable_image(event_dir, 'logo')
  raise "missing event logo in #{quote(event_dir)}" if image.nil?

  output_image = make_file_path('images/photo-events', event_slug, 'logo.webp')
  `convert #{Shellwords.escape(image)} -resize "x500>" -quality 80 #{Shellwords.escape(output_image)}`
end

def add_photos(event_dir, event_data)
  photos_dir = File.join(event_dir, 'photos')
  raise "missing photos directory in #{quote(event_dir)}" unless File.directory?(photos_dir)
  
  event_data['photos'] = []
  expanded_children(photos_dir).each do |child|
    raise "found incompatible file #{quote(child)} in #{quote(photos_dir)}" unless convertable_image?(child)
    add_photo(child, event_data)
  end
end

def add_photo(photo, event_data)
  photo_name = File.basename(photo, File.extname(photo))
  event_data['photos'] << photo_name
  output_image = make_file_path('images/photo-events', event_data['slug'], 'photos', "#{photo_name}.webp")
  output_thumbnail_image = make_file_path('images/photo-events', event_data['slug'], 'thumbnails', "#{photo_name}.webp")
  `convert #{Shellwords.escape(photo)} -resize "x900>" -quality 90 #{Shellwords.escape(output_image)}`
  `convert #{Shellwords.escape(photo)} -resize "x400>" -quality 75 #{Shellwords.escape(output_thumbnail_image)}`
end

run_with_context
