require 'minitest/autorun'

module tr1b
  class TestPlayer < MiniTest::Test
    def test_card_nil_on_start
      assert_nil Player.new.card
    end
  end
end
