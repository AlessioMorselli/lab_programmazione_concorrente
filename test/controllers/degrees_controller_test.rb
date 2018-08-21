require 'test_helper'

class DegreesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
    @degree = degrees(:degree_1)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should show degree courses" do
    log_in_as(@user)

    get degree_path(@degree)
    assert_response :success
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not show degree courses if not logged in" do
    get degree_path(@degree)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end
end
