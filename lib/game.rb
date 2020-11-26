module Tr1b
  class Game
    attr_accessor :players

    def initialize
      @players = []
      @room_a = []
      @room_b = []
    end

    ##
    # Sets a room for each joined player
    
    def set_player_rooms
      raise 'Not implemented'
    end

    def president_and_bomber_in_same_room?
      raise 'Not implemented'
    end
  end
end
