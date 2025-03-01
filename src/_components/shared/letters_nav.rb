class Shared::LettersNav < Bridgetown::Component
  def initialize(console:, current_letter:)
    @console = console
    @current_letter = current_letter
  end
end
