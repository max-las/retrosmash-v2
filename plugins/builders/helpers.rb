module Builders
  class Helpers < SiteBuilder
    JS_TEMPLATES_DIR = 'frontend/javascript/templates/'.freeze
    JS_MODELS_DIR = 'frontend/javascript/models/'.freeze

    def build
      helper :class_names do |*classes, **conditional_classes|
        conditional_classes.each do |class_name, condition|
          classes << class_name if condition
        end
        classes.join(' ')
      end
    end
  end
end
