# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

    # Preview this email at
    # http://localhost:3000/rails/mailers/user_mailer/invite_to_group_not_expiration
    def invite_to_group_not_expiration
        invitation = Invitation.second
    
        InvitationMailer.invite_to_group(invitation)
    end
  
    # Preview this email at
    # http://localhost:3000/rails/mailers/user_mailer/invite_to_group_expiration
    def invite_to_group_expiration
        invitation = Invitation.first

        InvitationMailer.invite_to_group(invitation)
    end
  
end