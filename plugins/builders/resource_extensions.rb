class Builders::ResourceExtensions < SiteBuilder
  def build
    define_resource_method :enhanced_model do
      model.tap { |instance| instance.assign_attributes(data) }
    end
  end
end
