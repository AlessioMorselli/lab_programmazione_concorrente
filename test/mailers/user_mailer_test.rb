require 'test_helper'
 
class UserMailerTest < ActionMailer::TestCase
    def setup
        @user = users(:luigi)
    end

    test "should send a confermation email" do
        @user.confirm_token = User.new_token
        email = UserMailer.registration_confirmation(@user)

        assert_emails 1 do
            email.deliver_now
        end

        assert_equal ['noreply@unife.study.groups.it'], email.from
        assert_equal [@user.email], email.to
        assert_equal 'Conferma Registrazione', email.subject
    end
  
    test "should send a reset email" do
        @user.reset_token = User.new_token
        email = UserMailer.password_reset(@user)

        assert_emails 1 do
            email.deliver_now
        end

        assert_equal ['noreply@unife.study.groups.it'], email.from
        assert_equal [@user.email], email.to
        assert_equal 'Reset della password', email.subject
    end
end