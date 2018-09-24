require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :users, :courses

  def setup
    #
  end

  test "should not save if the name of the course is not supplied" do
    assert_not Course.new.save
  end

end