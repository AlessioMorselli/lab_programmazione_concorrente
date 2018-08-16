require 'test_helper'

class DegreesCoursesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
    log_in_as(@user)
  end

  test "should index groups of every degree course" do
    get degrees_courses_path
    assert_response :success
  end
end
