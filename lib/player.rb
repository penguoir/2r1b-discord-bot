module Tr1b
  ##
  # A player represents an individual who is playing 2r1b.

  class Player
    attr_accessor :card
    attr_accessor :room

    def initialize
      @card = Card.new
    end
  end
end
