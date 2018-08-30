require 'test_helper'

class ConfirmEmailTest < ActionDispatch::IntegrationTest
    def setup
        # Creo un nuovo utente, che verrà registrato
        @user = User.new
        @user.name = "The Evil Skeletor"
        @user.email = "skeletor@theevil.com"
        @user.password = "hemansucks"
        @year = 1
        @degree = degrees(:ingegneria_informatica)

    end

    test "new user should confirm email before log in for the first time" do
        # Registro il nuovo utente
        post signup_path, params: { user: {
            name: @user.name,
            password: @user.password,
            email: @user.email,
            degree_id: @degree.id,
            year: @year
            }
        }

        @user = User.find_by_name("The Evil Skeletor")

        # Verifico che l'utente sia stato registrato, ma non loggato
        assert_not is_logged_in?
        assert_not @user.nil?

        # Verifico che esista il token di conferma e che confirmed sia false
        assert_not @user.confirmed?
        # assert_not @user.confirm_token.nil?

        # Verifico la ridirezione a landing_path
        assert_redirected_to landing_path

        # Simulo il clic dell'utente sul link della mail
        get edit_confirm_account_path(@user.confirm_token, email: @user.email)
        @user.reload

        # Verifico che il token di conferma sia stato cancellato e che confirmed sia ora a true
        assert @user.confirmed?
        # assert @user.confirm_token.nil?

        # Verifico che ora l'utente sia loggato e la ridirezione a groups_path
        assert is_logged_in?
        assert_redirected_to groups_path
    end
    
    test "should not login if confirm token is not correct" do
        # Registro il nuovo utente
        post signup_path, params: { user: {
            name: @user.name,
            password: @user.password,
            email: @user.email,
            degree_id: @degree.id,
            year: @year
            }
        }

        @user = User.find_by_name("The Evil Skeletor")

        # Verifico che l'utente sia stato registrato, ma non loggato
        assert_not is_logged_in?
        assert_not @user.nil?

        # Verifico che esista il token di conferma e che confirmed sia false
        assert_not @user.confirmed?
        # assert_not @user.confirm_token.nil?

        # Verifico la ridirezione a landing_path
        assert_redirected_to landing_path

        # Simulo il clic dell'utente sul link della mail
        get edit_confirm_account_path("token puzzone", email: @user.email)
        @user.reload

        # Verifico che il token di conferma sia stato cancellato e che confirmed sia ora a true
        assert_not @user.confirmed?
        # assert_not @user.confirm_token.nil?

        # Verifico che ora l'utente non sia loggato e la ridirezione a landing_path
        assert_not is_logged_in?
        assert_redirected_to landing_path
    end
end