require "node-runner"

class Builders::Helpers < SiteBuilder
  JS_TEMPLATES_DIR = 'frontend/javascript/templates/'.freeze
  JS_MODELS_DIR = 'frontend/javascript/models/'.freeze

  def build
    helper :class_names do |*classes, **conditional_classes|
      conditional_classes.each do |class_name, condition|
        classes << class_name if condition
      end
      classes.join(' ')
    end

    helper :render_js_model_template do |template_name, model|
      model_name = model.model_name.name
      model_path = File.expand_path(File.join(JS_MODELS_DIR, "#{model_name}.js"))
      template_path = File.expand_path(File.join(JS_TEMPLATES_DIR, "#{template_name}.js"))
      runner = NodeRunner.new(
        <<~JS
          import { #{template_name} } from '#{template_path}';
          import { #{model_name} } from '#{model_path}';
  
          const model = new #{model_name}(JSON.parse("#{model.to_json.gsub('"', '\"')}"));
  
          export const template = () => #{template_name}(model);
        JS
      )
    
      runner.template.html_safe
    end
  end
end
