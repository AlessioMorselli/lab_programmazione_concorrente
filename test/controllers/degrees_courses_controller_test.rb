require 'test_helper'

class DegreesCoursesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
  end

  ### TEST PER UN UTENTE LOGGATO ###
  test "should index groups of every degree course" do
    log_in_as(@user)

    get degrees_courses_path
    assert_response :success
  end

  ### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index groups of every degree course if not logged in" do
    get degrees_courses_path
    assert_redirected_to login_path
    assert_not flash.empty?
  end
end
