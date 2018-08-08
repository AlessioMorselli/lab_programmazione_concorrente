class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    # TODO: definire come devo restituire i dati a Mirko

    # GET users_path
    def index
        # Restituisce la lista di tutti gli utenti (solo a fine di development)
    end

    # GET signup_path
    def new
        # Visualizza la form per l'iscrizione al sito
        @user = User.new
    end

    # POST signup_path
    def create
        # Salva nel database un nuovo utente
        @user = User.new(user_params)
        if @user.save
            log_in user
            redirect_to groups_path
        else
            render 'new'
        end
    end

    # GET edit_user_path(user)
    def edit
        # Visualizza la form per modificare le informazioni di un utente
    end

    # PUT/PATCH user_path(user)
    def update
        # Aggiorna le informazioni sul un utente
        if @user.update
            flash[:success] = 'Le tue informazioni sono state aggiornate'
            redirect_to groups_path
        else
            render 'edit'
        end
    end

    # DELETE group_path(group)
    def destroy
        # Cancella un utente dall'applicativo
        @user.destroy
        redirect_to login_path
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def group_params
      params.require(:user).permit(:name, :email)
    end
end
