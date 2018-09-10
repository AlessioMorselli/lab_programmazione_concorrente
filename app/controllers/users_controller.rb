class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update] #[:edit, :update, :destroy]
    before_action :logged_in_user, only: [:edit, :update] #[:edit, :update, :destroy]
    before_action only: [:edit, :update] do #[:edit, :update, :destroy]
        correct_user params[:id]
    end

    # TODO: da togliere
    # GET users_path
    def index
        # Restituisce la lista di tutti gli utenti (solo a fine di development)
        @users = User.all

        render json: @users
    end

    # GET signup_path
    def new
        # Visualizza la form per l'iscrizione al sito
        @user = User.new
        render file: "app/views/signup_page"
    end

    # POST signup_path
    def create
        # Salva nel database un nuovo utente
        @user = User.new(user_params)
        if @user.save
            # log_in @user
            # redirect_to groups_path
            @user.send_confirm_email
            flash[:info] = "Per piacere, controlla la tua casella di posta elettronica e 
                                conferma il tuo indirizzo email prima di continuare!"
            # TODO: metti la ridirezione corretta
            redirect_to landing_path
        else
            flash.now[:error] = "Ooooppss, qualcosa è andato storto!"
            render file: "app/views/signup_page"
        end
    end

    # GET edit_user_path(user)
    def edit
        # Visualizza la form per modificare le informazioni di un utente
        render json: @user
    end

    # PUT/PATCH user_path(user)
    def update
        # Aggiorna le informazioni su un utente
        if @user.update(user_params)
            flash[:success] = 'Le tue informazioni sono state aggiornate'
            redirect_to groups_path
        else
            flash.now[:error] = "Ooooppss, qualcosa è andato storto!"
            # TODO: metti il template corrispondente alla modifica di un utente
            # render file: "app/views/edit_user_page"
        end
    end

    # DELETE user_path(user)
    # def destroy
    #     # Cancella un utente dall'applicativo
    #     @user.destroy
    #     redirect_to login_path
    # end

    # GET user_confirm_email_path(id: user.id, confirm_token: user.email_confirm_token)
    def confirm_email
        user = User.find_by_email_confirm_token(params[:confirm_token])
        if user
            user.email_activate
            flash[:success] = "La tua email è stata confermata! Benvenuto!"
            log_in user
            remember(user)
            redirect_to groups_path
        else
            flash[:error] = "Siamo spiacenti, ma pare che l'utente non esista."
            redirect_to login_path
        end
    end

    private
    def set_user
        begin
            @user = User.find(params[:id]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end

    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation,
                                        student_attributes: [:degree_id, :year])
    end
end
