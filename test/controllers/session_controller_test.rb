require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test "should show login page" do
    get login_path
    assert_response :success
  end
end
