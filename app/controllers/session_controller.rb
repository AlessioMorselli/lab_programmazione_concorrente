class SessionController < ApplicationController
    # GET login_path
    def new
        # Visualizza la form per permettere il log in
        # TODO: da cambiare con quello vero
        render file: 'app/views/login_page'
    end

    # POST login_path
    def create
        # Esegue il log in e ridireziona a groups_path
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
            log_in user
            params[:session][:remember_me] == '1' ? remember(user) : forget(user)
            redirect_back_or groups_path
        else
            flash.now[:danger] = 'Email o password sbagliate'
            render file: 'app/views/login_page'
        end
    end

    # DELETE logout_path
    def destroy
        # Esegue il log out di un utente
        log_out if logged_in?
        redirect_to login_path
    end

    # GET landing_path
    def landing
        render file: 'app/views/landing_page'
    end
end
