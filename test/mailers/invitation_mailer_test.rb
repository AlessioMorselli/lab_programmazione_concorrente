require 'test_helper'
 
class InvitationMailerTest < ActionMailer::TestCase
    def setup
        @invitation = invitations(:invito_ninja_giovanni)
    end

    test "should send an invitation email" do
        email = InvitationMailer.invite_to_group(@invitation)

        assert_emails 1 do
            email.deliver_now
        end

        assert_equal ['unife.community@unife.study.groups.it'], email.from
        assert_equal ['giovanni@unife.it'], email.to
        assert_equal 'Sei stato invitato al gruppo ninja', email.subject
    end
  
end