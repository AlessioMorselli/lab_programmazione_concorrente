require 'test_helper'

class DegreesControllerTest < ActionDispatch::IntegrationTest
  fixtures :degrees, :degrees_courses, :courses

  test "should show degree courses" do
    get degree_path(:degree_1)
    assert_response :success
  end
end
