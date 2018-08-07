require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get login_path
    assert_response :success
  end
end
