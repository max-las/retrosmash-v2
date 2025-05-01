class Photo < Bridgetown::Model::Base
  def path
    File.join('images/photo-events', photo_event.slug, 'photos', "#{name}.webp")
  end

  def thumbnail_path
    File.join('images/photo-events', photo_event.slug, 'thumbnails', "#{name}.webp")
  end
end
