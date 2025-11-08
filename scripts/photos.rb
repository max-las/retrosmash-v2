require_relative '_shared'

DIRS_TO_REPLACE = %w[
  _photo_events
  _photos
  images/photo-events
].freeze
PHOTO_EVENT_DEFAULTS = { layout: 'photo_event' }.freeze

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  create_photo_event_defaults
  dir_children(@source_dir).each do |child|
    create_photo_event_resource(child) if File.directory?(child)
  end
end

def create_photo_event_defaults
  defaults_file = make_file_path('_photo_events', '_defaults.yml')
  File.write(defaults_file, PHOTO_EVENT_DEFAULTS.to_yaml(stringify_names: true))
end

def create_photo_event_resource(dir)
  data = parse_photo_event_data(dir)
  slug = slugify(data['title'])
  create_photo_resources(dir, slug)
  data['logo_path'] = convert_event_logo(dir, slug)
  resource = make_file_path('_photo_events', "#{slug}.html")
  File.write(resource, "#{data.to_yaml}---")
end

def parse_photo_event_data(event_dir)
  data_file = File.join(event_dir, 'data.yml')
  raise "missing event data in #{quote(event_dir)}" unless File.file?(data_file)

  YAML.load_file(data_file)
end

def create_photo_resources(event_dir, event_slug)
  photos_dir = File.join(event_dir, 'photos')
  raise "missing photos directory in #{quote(event_dir)}" unless File.directory?(photos_dir)

  create_photo_defaults(event_slug)
  dir_children(photos_dir).each do |photo|
    next unless File.file?(photo)
    raise "found incompatible file #{quote(photo)} in #{quote(photos_dir)}" unless convertable_image?(photo)

    create_photo_resource(photo, event_slug)
  end
end

def create_photo_defaults(event_slug)
  defaults = { photo_event: event_slug }
  defaults_file = make_file_path('_photos', event_slug, '_defaults.yml')
  File.write(defaults_file, defaults.to_yaml(stringify_names: true))
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
  data = { name:, **dimensions, image_path:, thumbnail_path: }
  resource = make_file_path('_photos', event_slug, "#{slug}.html")
  File.write(resource, "#{data.to_yaml(stringify_names: true)}---")
end

def convert_event_logo(event_dir, event_slug)
  image = find_convertable_image(event_dir, 'logo')
  raise "missing event logo in #{quote(event_dir)}" if image.nil?

  relative_path = "images/photo-events/#{event_slug}/logo.webp"
  output_image = make_file_path(relative_path)
  convert_and_resize_image(input_path: image, output_path: output_image, height: 500, quality: 80)
  relative_path
end

run_with_context
