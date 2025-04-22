require_relative '_shared'

@source_file = ARGV[0]

if @source_file.blank?
  raise 'input file must be specified'
end

unless File.file?(@source_file)
  raise 'specified file not found'
end

def run
  filename = File.basename(@source_file, File.extname(@source_file))
  convert_and_resize_image(
    input_path: @source_file,
    output_path: make_file_path('images', 'events', "#{filename}.webp"),
    height: 900,
    quality: 80
  )
end

run_with_context
