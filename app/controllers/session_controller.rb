class SessionController < ApplicationController
    # GET login_path
    def new
        # Visualizza la form per permettere il log in
        unless logged_in?
            render file: 'app/views/login_page'
        else
            flash[:info] = "Sei già loggato"
            redirect_to groups_path
        end
    end

    # POST login_path
    def create
        # Esegue il log in e ridireziona a groups_path
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
            if user.confirmed?
                log_in user
                params[:session][:remember_me] == '1' ? remember(user) : forget(user)
                redirect_back_or groups_path
            else
                flash[:warning] = 'Per piacere, attiva il tuo account seguendo le istruzioni
                                nella email di conferma che hai ricevuto per procedere'
                redirect_to landing_path
            end
        else
            flash.now[:error] = 'Email e/o password sbagliate'
            render file: 'app/views/login_page'
        end
    end

    # GET logout_path
    def destroy
        # Esegue il log out di un utente
        forget current_user if logged_in?
        log_out if logged_in?
        redirect_to login_path
    end

    # GET landing_path
    def landing
        # unless logged_in?
            render file: 'app/views/landing_page'
        # else
        #     flash[:info] = "Sei già loggato"
        #     redirect_to groups_path
        # end
    end
end
