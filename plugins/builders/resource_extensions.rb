class Builders::ResourceExtensions < SiteBuilder
  def build
    define_resource_method :model_with_data do
      model.assign_attributes(data) 
      model
    end
  end
end
