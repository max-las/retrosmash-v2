class BaseModel < Bridgetown::Model::Base
  delegate :relative_url, to: :resource

  def resource
    @resource ||= render_as_resource
  end
end
