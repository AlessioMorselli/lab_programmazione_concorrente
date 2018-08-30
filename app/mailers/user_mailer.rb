class UserMailer < ApplicationMailer
    
    def registration_confirmation(user)
        @user = user
        mail to: "#{@user.name} <#{@user.email}>", subject: "Conferma Registrazione"
    end

    def password_reset(user)
        @user = user
        mail to: "#{@user.name} <#{@user.email}>", subject: "Reset della password"
    end
end