class PhotoEvent < Bridgetown::Model::Base
  def photos
    @photos ||= site.data.photos[slug].map do |photo_data|
      Photo.new(**photo_data, photo_event: self)
    end
  end
end
