class Builders::Helpers < SiteBuilder
  def build
    helper :class_names do |*classes, **conditional_classes|
      conditional_classes.each do |class_name, condition|
        classes << class_name if condition
      end
      classes.join(' ')
    end
  end
end
