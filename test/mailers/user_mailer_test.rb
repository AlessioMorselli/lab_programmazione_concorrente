require 'test_helper'
 
class UserMailerTest < ActionMailer::TestCase
    def setup
        @user = User.new
        @user.email = "cool.email@cool.it"
        @user.name = "CoolName"
        @user.password = "InvinciblePassword"
        @user.save!
        @user.reload
    end

    test "should send a confermation email" do
        email = UserMailer.registration_confirmation(@user)

        assert_emails 1 do
            email.deliver_now
        end

        assert_equal ['unife.community@unife.study.groups.it'], email.from
        assert_equal ['cool.email@cool.it'], email.to
        assert_equal 'Conferma Registrazione', email.subject
    end
  
end