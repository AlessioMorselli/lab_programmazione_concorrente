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
    end

    # POST signup_path
    def create
        # Salva nel database un nuovo utente
    end

    # GET edit_user_path(user)
    def edit
        # Visualizza la form per modificare le informazioni di un utente
    end

    # PUT/PATCH user_path(user)
    def update
        # Aggiorna le informazioni sul un utente
    end

    # DELETE group_path(group)
    def destroy
        # Cancella un utente dall'applicativo
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def group_params
      params.require(:user).permit(:name, :email)
    end
end
