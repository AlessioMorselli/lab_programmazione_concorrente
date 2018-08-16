require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    def setup
        @user = users(:user_1)
    end

    test "should not login with invalid information" do
        get login_path
        assert_template 'sessions/new' # TODO: sistema con il template corrispondente
        post login_path, params: { session: { email: "", password: "" } }
        assert_template 'sessions/new' # TODO: sistema con il template corrispondente
        assert_not flash.empty?
    end

    test "should login with valid information followed by logout" do
        get login_path
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciao" } }
        assert_redirected_to groups_path
        assert is_logged_in?

        delete logout_path
        assert_not is_logged_in?
        assert_redirected_to login_path
    end

    test "should login with valid information followed by double logout" do
        user = users(:user_1)
        get login_path
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciao" } }
        assert_redirected_to groups_path
        assert is_logged_in?
        follow_redirect!
        assert_template 'users/show' # TODO: sistema con il template corrispondente
        assert_select "a[href=?]", login_path, count: 0
        assert_select "a[href=?]", signup_path, count: 0
        assert_select "a[href=?]", logout_path

        delete logout_path
        assert_not is_logged_in?
        assert_redirected_to login_path

        # Simulate user clicking logout in a second window
        delete logout_path

        follow_redirect!
        assert_select "a[href=?]", signup_path
        assert_select "a[href=?]", logout_path,      count: 0
    end

    test "login with remembering" do
        log_in_as(@user, remember_me: '1')
        assert_not_empty cookies['remember_token']
    end
    
    test "login without remembering" do
        # Log in to set the cookie.
        log_in_as(@user, remember_me: '1')
        # Log in again and verify that the cookie is deleted.
        log_in_as(@user, remember_me: '0')
        assert_empty cookies['remember_token']
    end
end
