ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  # Restituisce true se un utente di test è loggato
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logga come l'utente indicato
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # Logga come l'utente indicato
  def log_in_as(user, password: 'ciaone', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end

  # Setter per il cookie dell'ultimo messaggio letto
  def set_last_message_cookies(user, group, time)
    cookies[user.id.to_s + group.uuid] = time
  end
end
