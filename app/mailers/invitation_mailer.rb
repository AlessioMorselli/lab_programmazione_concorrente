class InvitationMailer < ActionMailer::Base
    def registration_confirmation(invitation)
        @invitation = invitation
        @user = @invitation.user
        @group = @invitation.group
        mail(to: "#{@user.name} <#{@user.email}>", subject: "Sei stato invitato al gruppo #{@group.name}")
    end
end