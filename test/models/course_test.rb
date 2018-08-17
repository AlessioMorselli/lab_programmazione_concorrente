require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :users, :courses

  def setup
    #
  end

  test "should not save if the the name of the course is not unique" do
    course = Course.new(name: courses(:course_1).name)
    assert_not course.save
  end

end