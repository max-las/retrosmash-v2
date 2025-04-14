class PhotoEvent < Bridgetown::Model::Base
  def photos_with_paths
    photos.map do |photo|
      { name: photo, path: photo_path(photo), thumbnail_path: thumbnail_path(photo) }
    end
  end

  def thumbnail_path(photo)
    File.join('/images/photo-events', slug, 'thumbnails', "#{photo}.webp")
  end

  def photo_path(photo)
    File.join('/images/photo-events', slug, 'photos', "#{photo}.webp")
  end
end
