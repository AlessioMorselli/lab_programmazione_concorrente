require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test "should show landing page" do
    get landing_path
    assert_response :success

    assert_select "a[href=?]", landing_path, minimum: 0
    assert_select "a[href=?]", login_path, minimum: 1
    assert_select "a[href=?]", signup_path, minimum: 1
    assert_select "a[href=?]", logout_path, count: 0
  end

  test "should show login page" do
    get login_path
    assert_response :success

    assert_select "a[href=?]", landing_path, minimum: 1
    assert_select "a[href=?]", login_path, minimum: 0
    assert_select "a[href=?]", signup_path, minimum: 1
    assert_select "a[href=?]", logout_path, count: 0
  end
end
