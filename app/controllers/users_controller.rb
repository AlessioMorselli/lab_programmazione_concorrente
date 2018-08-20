class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :logged_in_user, only: [:edit, :update, :destroy]
    before_action only: [:edit, :update, :destroy] do
        correct_user(params[:id])
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
        render json: @user
    end

    # POST signup_path
    def create
        # Salva nel database un nuovo utente
        @user = User.new(user_params)
        if @user.save!
            log_in @user
            redirect_to groups_path
        else
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
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
        if @user.update!(user_params)
            flash[:success] = 'Le tue informazioni sono state aggiornate'
            redirect_to groups_path
        else
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
        end
    end

    # DELETE user_path(user)
    def destroy
        # Cancella un utente dall'applicativo
        @user.destroy
        redirect_to login_path
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end
end
