class Console < BaseModel
  def full_name
    name.include?(publisher) ? name : "#{publisher} #{name}"
  end

  def logo_path
    "images/consoles/#{slug}/logo.#{logo_format}"
  end

  def logo_alt
    "logo de la #{name}"
  end

  def image_path
    "images/consoles/#{slug}/console.webp"
  end

  def image_alt
    "console #{full_name}"
  end
end
