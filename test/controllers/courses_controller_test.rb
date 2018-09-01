require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:luigi)
    @degree = degrees(:ingegneria_informatica)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should show courses of the specified degree" do
    log_in_as @user

    get degree_courses_path(@degree, year: 1)
    assert_response :success

    assert_equal 1, assigns(:courses).length
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not show courses of the specified degree if not logged in" do
    get degree_courses_path(@degree, year: 1)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end
end
