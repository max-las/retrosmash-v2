class Console < Bridgetown::Model::Base
  def full_name
    name.include?(publisher) ? name : "#{publisher} #{name}"
  end

  def logo_alt
    "logo de la #{name}"
  end

  def image_alt
    "console #{full_name}"
  end
end
