class GroupsController < ApplicationController
    before_action :set_group, only: [:show, :edit, :update, :destroy]

    # TODO: definire come devo restituire i dati a Mirko

    # GET groups_path
    def index
        # Restituisce tutti i gruppi, inserendovi anche dei parametri di ricerca (?)
        # Lo faccio in relazione a corso di laurea e anno dell'utente
        # Parametri di ricerca da mettere come query parameters nella URL
        if params['query']
            if params['query'].is_a?
                query = params['query'][0]
            else query = params['query']
            end
            @groups = Group.user_query(query) # Scope che cerca sia nel nome, che nel corso di un gruppo
        else
            #@groups = Group.suggested # Scope che restituisce 10 - 12 gruppi che potrebbero interessare
                                      # all'utente loggato
            @groups = Group.all
        end
    end

    # GET group_path(group)
    def show
        # Visualizza la chat di un gruppo, inclusi messaggi, eventi e membri (online ed offline)
        @messages = @group.messages.recent # Scope che definisce di cercare solo i messaggi più recenti
        @events = @group.events.this_month # Ho pensato che possiamo caricare solo gli eventi del mese,
                                           # quindi caricarne altri nel caso vengano richiesti
        @memberships = @group.memberships
    end

    # GET new_groups_path
    def new
        # Visualizza la form per creare un nuovo gruppo
        @group = Group.new
    end

    # POST groups_path
    def create
        # Salva il gruppo inviato nel DB
        @group = Group.new(group_params)
        successful = false
        
        Group.transaction do
            @group.save

            first_member = Membership.new
            first_member.admin = true
            first_member.user_id = current_user.id
            first_member.group_id = @group.id
            first_member.save
            successful = true
        end

        if successful
            redirect_to group_path(@group)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono valide'
            render 'new'
        end
    end

    # GET edit_groups_path
    def edit
        # Visualizza la form per modificare un nuovo gruppo
    end

    # PUT/PATCH group_path(group)
    def update
        # Aggiorna le informazioni sul gruppo
        if @group.update(group_params)
            redirect_to group_path(@group)
        else
            flash.now[:danger] = 'Le informazioni del gruppo non sono state aggiornate'
            render 'edit'
        end
    end

    # DELETE group_path(group)
    def destroy
        # Cancella un gruppo, compresi tutti i messaggi e gli eventi, nonché le relazioni
        # con le altre tabelle (inviti, membri)
        @group.destroy

        redirect_to groups_path
    end

    private
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :max_members, :private, :course_id)
    end
end
