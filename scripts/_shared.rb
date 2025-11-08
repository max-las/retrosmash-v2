# not a script, this is common logic to be included in actual scripts

require 'bridgetown-core'
require 'active_support/all'
require 'rmagick'

Dir.glob(File.join(Dir.pwd, 'models', '**', '*.rb')).each do |file|
  require file
end

CONVERTABLE_IMAGE_EXTENSIONS = %w[jpg jpeg png].freeze
OUTPUT_DIR = 'src'.freeze
CONSTRUCTION_DIR = File.join('under_construction', OUTPUT_DIR)

def run_with_context
  FileUtils.remove_entry(CONSTRUCTION_DIR) if File.exist?(CONSTRUCTION_DIR)
  run
  if self.class.const_defined?(:DIRS_TO_REPLACE)
    DIRS_TO_REPLACE.each { FileUtils.remove_dir(File.join(OUTPUT_DIR, it)) }
  end
  FileUtils.copy_entry(CONSTRUCTION_DIR, 'src')
  FileUtils.remove_dir(CONSTRUCTION_DIR)
end

def dir_children(dir)
  Dir.children(dir).map { |child| File.join(dir, child) }
end

def slugify(string)
  string.parameterize # removes special characters, unlike Bridgetown::Utils.slugify
end

def quote(string)
  "\"#{string}\""
end

def make_file_path(*segments)
  File.join(CONSTRUCTION_DIR, *segments).tap do |output_path|
    FileUtils.mkpath(File.dirname(output_path))
  end
end

def find_convertable_image(dir, filename)
  CONVERTABLE_IMAGE_EXTENSIONS.each do |extension|
    candidate = File.join(dir, "#{filename}.#{extension}")
    return candidate if File.file?(candidate)
  end
  nil
end

def convertable_image?(filename)
  File.file?(filename) && CONVERTABLE_IMAGE_EXTENSIONS.include?(File.extname(filename).delete('.'))
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
