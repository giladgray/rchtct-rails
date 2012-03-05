require 'test_helper'

class DesignTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Design.new.valid?
  end
end
