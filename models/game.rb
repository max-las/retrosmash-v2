class Game < Bridgetown::Model::Base
  def self.from_data(data:, console:)
    new(**data, data:, console:)
  end

  def to_json(*_args)
    data.merge(console_slug: console.slug).to_json
  end
end
