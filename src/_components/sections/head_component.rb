module Sections
  class HeadComponent < Bridgetown::Component
    def initialize(title:, subtitle: nil, breadcrumb: nil)
      @title = title
      @subtitle = subtitle
      @breadcrumb = breadcrumb
    end
  end
end
