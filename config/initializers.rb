require 'active_support/all'

Bridgetown.configure do |config|
  # For documentation on how to configure your site using this initializers file,
  # visit: https://www.bridgetownrb.com/docs/configuration/initializers/

  config.autoload_paths << {
    path: "models",
    eager: true
  }

  collections do
    sections do
      output true
      permalink "/:slug/"
      sort_by "rank"
    end

    game_consoles do
      output true
      permalink "/consoles/:slug/"
      sort_by "publisher"
      relations do
        has_many "games"
      end
    end

    games do
      output false
      relations do
        belongs_to "game_console"
      end
    end

    photo_events do
      output true
      permalink "/photo-events/:slug/"
      sort_by "title"
      relations do
        has_many "photos"
      end
    end

    photos do
      output false
      relations do
        belongs_to "photo_event"
      end
    end
  end
end
