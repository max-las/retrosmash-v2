require_relative '_shared'

@source_dir = ARGV[0]

if @source_dir.blank?
  raise 'input directory must be specified'
end

unless File.directory?(@source_dir)
  raise 'specified directory not found'
end

def run
  dir_children(@source_dir).each do |child|
    convert(child) if File.file?(child)
  end
end

def convert(image)
  filename = File.basename(image, File.extname(image))
  convert_and_resize_image(
    input_path: image,
    output_path: make_file_path('images', File.basename(@source_dir), "#{filename}.webp"),
    quality: 95
  )
end

run_with_context
