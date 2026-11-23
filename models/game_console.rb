class GameConsole < Bridgetown::Model::Base
  # The full_name data, when given, overrides the name derived from the publisher.
  def full_name
    attributes['full_name'].presence || (name.include?(publisher) ? name : "#{publisher} #{name}")
  end

  def logo_alt
    "logo de la #{name}"
  end

  def image_alt
    "console #{full_name}"
  end
end
