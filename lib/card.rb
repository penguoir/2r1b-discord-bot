module Tr1b
  class Card
    attr_accessor :team
    attr_accessor :name
    attr_accessor :helper_text

    def self.setup_as(team, role)
      c = new
      c.team = team

      case role
      when :bomber
        c.name = 'Bomber'
        c.helper_text = "Be in the same room as the president."
      when :president
        c.name = 'President'
        c.helper_text = "Be in a different room to the bomber."
      end

      return c
    end
  end
end
