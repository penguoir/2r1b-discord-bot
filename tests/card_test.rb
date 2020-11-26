require 'minitest/autorun'

require_relative '../lib/card'

module Tr1b
  class CardTest < MiniTest::Test
    def test_setup_as_bomber
      @c = Card.setup_as(:red, :bomber)
      assert_equal "Bomber", @c.name 
    end
  end
end
