# not a script, this is common logic to be included in actual scripts
# consoles, games and photos are handled by bridgetown-prep instead, see how-to.md

require 'active_support/all'
require 'rmagick'

OUTPUT_DIR = 'src'.freeze
CONSTRUCTION_DIR = File.join('under_construction', OUTPUT_DIR)

def run_with_context
  FileUtils.rm_rf(CONSTRUCTION_DIR)
  run
  FileUtils.copy_entry(CONSTRUCTION_DIR, OUTPUT_DIR)
  FileUtils.remove_dir(CONSTRUCTION_DIR)
end

def dir_children(dir)
  Dir.children(dir).map { |child| File.join(dir, child) }
end

def make_file_path(*segments)
  File.join(CONSTRUCTION_DIR, *segments).tap do |output_path|
    FileUtils.mkpath(File.dirname(output_path))
  end
end

def convert_and_resize_image(input_path:, output_path:, quality:, height: nil)
  image = Magick::ImageList.new(input_path).first
  dimensions = { width: image.columns, height: image.rows }
  target_height = height || dimensions[:height]
  if dimensions[:height] > target_height
    aspect_ratio = dimensions[:width].to_f / dimensions[:height]
    target_width = (target_height * aspect_ratio).round
    image.scale!(target_width, target_height)
    dimensions = { width: target_width, height: target_height }
  end
  image.write(output_path) { |options| options.quality = quality }
  dimensions
end
