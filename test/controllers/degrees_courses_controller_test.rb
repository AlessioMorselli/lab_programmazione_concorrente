require 'test_helper'

class DegreesCoursesControllerTest < ActionDispatch::IntegrationTest
  fixtures :degrees, :courses, :degrees_courses

  test "index" do
    get degree_courses_path
    assert_response :success
  end

  test "show" do
    get degree_course_path(:degree_course_1)
    assert_response :success
  end
end
