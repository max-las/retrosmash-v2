module Shared
  class NavbarComponent < Bridgetown::Component
    def initialize(pages:)
      @pages = pages
    end
  end
end
