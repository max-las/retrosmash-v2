# How bridgetown-prep imports, reslugs, attaches assets to and removes the site's resources.
# Only Prep loads this file: the site builds without it. See how-to.md for the source layout and the commands.

require 'active_support/all'

# Slugs are parameterized, as they were before Prep, so that published URLs (/consoles/nintendo-64/) don't change.
parameterize = ->(text) { text.to_s.parameterize }

# The photos are displayed at most this high: PhotoSwipe needs the dimensions of the image it shows.
photo_height = 900
photo_data = lambda do |path|
  size = Bridgetown::Prep::Metadata.image.call(path)
  next size if size['height'] <= photo_height

  { 'width' => (size['width'] * photo_height.fdiv(size['height'])).round, 'height' => photo_height }
end

webp = ->(**options) { Bridgetown::Prep::Optimizers.image(format: 'webp', **options) }

Bridgetown::Prep.configure do
  # Relative, since pages resolve URLs against their <base> tag.
  assets_url 'assets'

  collection :game_consoles do
    slug { |console| parameterize.call(console.name) }
    extension 'html'
    image :image, required: true, optimize: webp.call(height: 500, quality: 80)
    image :logo, required: true # svg or webp, copied as is
  end

  collection :games do
    slug { |game| parameterize.call(game.title) }
    extension 'html'
    image :cover, required: true, optimize: webp.call(height: 500, quality: 80)
  end

  collection :photo_events do
    slug { |event| parameterize.call(event.title) }
    extension 'html'
    image :logo, required: true, optimize: webp.call(height: 500, quality: 80)
  end

  collection :photos do
    extension 'html'
    from_files as: :original, data: photo_data
    image :image, from: :original, optimize: webp.call(height: photo_height, quality: 90)
    image :thumbnail, from: :original, optimize: webp.call(height: 400, quality: 75)
  end
end
