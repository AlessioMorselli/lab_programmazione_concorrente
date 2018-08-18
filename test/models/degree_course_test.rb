require 'test_helper'

class DegreeCourseTest < ActiveSupport::TestCase
  fixtures :users, :degrees

  def setup
    @degree = Degree.new(name: "my_degree", years: 3)
    @degree.save
    @course = Course.new(name: "my_course")
    @course.save
  end

  test "should not save if no year is supplied" do
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id).save
  end

  test "should not save if year is greater than degree years" do
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, year: @degree.years+1).save
  end

end