#!/bin/bash

# imagemagick is required
# on ubuntu do:
#   sudo apt install imagemagick

supported_extensions=("jpg" "jpeg" "png")
input_dir="$1"
output_dir="$(dirname "$0")/../src/images/test"

while [ "${input_dir:0-1}" == "/" ]; do
  input_dir=${input_dir%?} 
done

if [ ! -d "$input_dir" ]; then
  echo "input directory not found"
  exit
fi

check_supported() {
  extension="$1"
  for supported_extension in "${supported_extensions[@]}"; do
    if [ "$extension" = "$supported_extension" ]; then
      return 1
    fi
  done
  return 0
}

for file in `find $input_dir -type f`; do
  filename_with_extension=$(basename "$file")
  filename="${filename_with_extension%.*}"
  extension="${filename_with_extension##*.}"
  relative_path_with_extension="${file#"$input_dir"}"
  relative_path_without_extension="${relative_path_with_extension%".$extension"}"
  check_supported $extension
  if [ $? -eq 1 ]; then
    output_filepath="$output_dir/$relative_path_without_extension.webp"
    mkdir -p $(dirname "$output_filepath")
    convert "$file" -resize "x500>" -quality 80 "$output_filepath"
  fi
done
