class GroupsController < ApplicationController
    before_action :set_group, only: [:show, :edit, :update, :destroy]

    # GET groups_path
    def index
        # Restituisce tutti i gruppi, inserendovi anche dei parametri di ricerca (?)
    end

    # GET group_path(group)
    def show
        # Visualizza la chat di un gruppo, inclusi messaggi, eventi e membri (online ed offline)
    end

    # GET new_groups_path
    def new
        # Visualizza la form per creare un nuovo gruppo
    end

    # POST groups_path
    def create
        # Salva il gruppo inviato nel DB
    end

    # GET edit_groups_path
    def edit
        # Visualizza la form per modificare un nuovo gruppo
    end

    # PUT/PATCH group_path(group)
    def update
        # Aggiorna le informazioni sul gruppo
    end

    # DELETE group_path(group)
    def destroy
        # Cancella un gruppo, compresi tutti i messaggi e gli eventi, nonché le relazioni
        # con le altre tabelle (inviti, membri)
    end

    private
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :max_members, :private, :course_id)
    end
end
