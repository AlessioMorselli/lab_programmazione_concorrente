class InvitationMailer < ApplicationMailer
    def invite_to_group(invitation)
        @invitation = invitation
        @user = @invitation.user
        @group = @invitation.group
        mail(to: "#{@user.name} <#{@user.email}>", subject: "Sei stato invitato al gruppo #{@group.name}")
    end
end