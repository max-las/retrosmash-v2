class Game < Bridgetown::Model::Base
  def to_json(*_args)
    data.merge(console_slug: console.slug).to_json
  end
end
