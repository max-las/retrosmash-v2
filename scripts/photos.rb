require_relative '_shared'

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  %w[
    _photo_events
    _photos
    images/photo-events
  ].each do |dir_to_remove|
    FileUtils.remove_dir(File.join(OUTPUT_DIR, dir_to_remove))
  end
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
    'Accueil' => '.',
    'Galerie photo' => 'gallery/',
    data['title'] => nil
  }
  convert_event_logo(event_dir, data['slug'])
  create_photo_event_resource(data)
  create_photo_resources(event_dir, data)
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

  output_image = make_file_path('images/photo-events/', event_slug, 'logo.webp')
  convert_and_resize_image(input_path: image, output_path: output_image, height: 500, quality: 80)
end

def create_photo_resources(event_dir, event_data)
  photos_dir = File.join(event_dir, 'photos')
  raise "missing photos directory in #{quote(event_dir)}" unless File.directory?(photos_dir)

  expanded_children(photos_dir).filter_map do |photo|
    next unless File.file?(photo)
    raise "found incompatible file #{quote(photo)} in #{quote(photos_dir)}" unless convertable_image?(photo)

    create_photo_resource(photo, event_data['slug'])
  end
end

def create_photo_resource(photo, event_slug)
  name = File.basename(photo, File.extname(photo))
  slug = name.parameterize
  image_path = "images/photo-events/#{event_slug}/photos/#{slug}.webp"
  output_image = make_file_path(image_path)
  thumbnail_path = "images/photo-events/#{event_slug}/thumbnails/#{slug}.webp"
  output_thumbnail_image = make_file_path(thumbnail_path)
  convert_and_resize_image(
    input_path: photo,
    output_path: output_thumbnail_image,
    height: 400,
    quality: 75
  )
  dimensions = convert_and_resize_image(
    input_path: photo,
    output_path: output_image,
    height: 900,
    quality: 90
  )
  data = { name:, slug:, **dimensions, photo_event: event_slug, image_path:, thumbnail_path: }
  resource = make_file_path('_photos', event_slug, "#{slug}.html")
  File.write(resource, "#{data.to_yaml(stringify_names: true)}---")
end

run_with_context
