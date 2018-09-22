require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:luigi)
  end

  test "should reset password" do
    # Primo tentativo: inserisco una mail non valida
    get new_password_reset_path
    # assert_template 'password_resets/new'

    post password_resets_path, params: {password_reset: {
      email: ""
    }}
    
    # La mail non può essere vuota!
    assert_not flash.empty?
    # assert_template 'password_resets/new'

    # Secondo tentativo: inserisco una mail corretta
    post password_resets_path, params: {password_reset: {
      email: @user.email
    }}

    # Confronto i due digest di reset: prima e dopo devono essere diversi
    assert_not_equal @user.reset_digest, @user.reload.reset_digest

    # Una mail è stato inviata!
    assert_equal 1, ActionMailer::Base.deliveries.size

    # Ora verifico la ridirezione a landing_path
    assert_not flash.empty?
    assert_redirected_to new_password_reset_path

    # Dal form di reset
    user = assigns(:user)

    # Primo tentativo: sbaglio la mail
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to new_password_reset_path

    # Secondo tentativo: sono un utente non confermato
    user.toggle!(:confirmed)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to new_password_reset_path
    user.toggle!(:confirmed)

    # Terzo tentativo: mail corretta, ma token errato
    get edit_password_reset_path('token sbagliato', email: user.email)
    assert_redirected_to new_password_reset_path

    # Quarto tentativo: finalmente ce la faccio!
    get edit_password_reset_path(user.reset_token, email: user.email)
    # assert_template 'password_resets/edit'
    # Il campo hidden con la mail DEVE essere presente
    # TODO: da scommentare
    # assert_select "input[name=email][type=hidden][value=?]", user.email

    # Primo tentativo di reset: password troppo corta
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {password: "ciao"}
    }

    # Secondo tentativo di reset: inserisco una password valida
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {password: "nuovapassword"}
    }

    # L'utente ora è loggato e reindirizzato a groups_path
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to groups_path
  end
end
