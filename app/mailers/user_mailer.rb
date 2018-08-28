class UserMailer < ActionMailer::Base
    default :from => "unife.community@unife.study.groups.it"
    
    def registration_confirmation(user)
        @user = user
        mail(to: "#{@user.name} <#{@user.email}>", subject: "Conferma Registrazione")
    end
end