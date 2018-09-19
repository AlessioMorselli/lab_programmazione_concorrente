require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
    def setup
        @user = users(:giorgio)
    end

    test "should not login with invalid information" do
        get login_path
        post login_path, params: { session: { email: "", password: "" } }
        assert_not flash.empty?
    end

    test "should login with valid information followed by logout" do
        get login_path
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciaone" } }
        assert_redirected_to groups_path
        assert is_logged_in?

        get logout_path
        assert_not is_logged_in?
        assert_redirected_to login_path
    end

    test "should login with valid information followed by double logout" do
        get login_path
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciaone" } }
        assert_redirected_to groups_path
        assert is_logged_in?
        follow_redirect!

        # assert_select "a[href=?]", login_path, count: 0
        # assert_select "a[href=?]", signup_path, count: 0
        # assert_select "a[href=?]", logout_path

        get logout_path
        assert_not is_logged_in?
        assert_redirected_to login_path

        # Simula il click su logout su un'altra finestra
        get logout_path

        follow_redirect!
        # assert_select "a[href=?]", signup_path
        # assert_select "a[href=?]", logout_path,      count: 0
    end

    test "login with remembering" do
        log_in_as(@user, remember_me: '1')
        assert_not_empty cookies['remember_token']
    end
    
    test "login without remembering" do
        # Il login imposta i cookie
        log_in_as(@user, remember_me: '1')
        # Un login senza 'ricordami' cancella i cookie
        log_in_as(@user, remember_me: '0')
        assert_empty cookies['remember_token']
    end
end
