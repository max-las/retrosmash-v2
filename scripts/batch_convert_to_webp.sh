#!/bin/bash

# imagemagick is required
# on ubuntu do:
#   sudo apt install imagemagick

supported_extensions=("jpg" "jpeg" "png")
input_dir="$1"
output_dir="$input_dir/webp"

if [ ! -d "$input_dir" ]; then
  echo "input directory not found"
  exit
fi

if test -d "$output_dir"; then
  rm -r "$output_dir"
fi
mkdir "$output_dir"

check_supported() {
  extension="$1"
  for supported_extension in "${supported_extensions[@]}"; do
    if [ "$extension" = "$supported_extension" ]; then
      return 1
    fi
  done
  return 0
}

for file in *; do
  if test -f "$file"; then
    filename="${file%.*}"
    extension="${file##*.}"
    check_supported "$extension"
    if [ $? -eq 1 ]; then
      convert "$file" -resize "x600>" -quality 80 "$output_dir/$filename.webp"
    fi
  fi
done
