class PhotoEvent < Bridgetown::Model::Base
  def gallery_id
    "#{title.parameterize}-gallery"
  end
end
