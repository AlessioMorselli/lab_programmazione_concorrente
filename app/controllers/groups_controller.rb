class GroupsController < ApplicationController
    layout "main"
    before_action :set_group, only: [:show, :edit, :update, :destroy]
    before_action :logged_in_user
    before_action only: [:show] do
        is_member_in @group
    end
    before_action only: [:edit, :update, :destroy] do
        is_super_admin_in @group
    end
    before_action :set_degrees, only: [:new, :create, :edit, :update]

    # GET groups_path
    def index
        # Restituisce tutti i gruppi, inserendovi anche dei parametri di ricerca (?)
        # Lo faccio in relazione a corso di laurea e anno dell'utente
        # Parametri di ricerca da mettere come query parameters nella URL
        if params['query']
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['query'].is_a? Array
                query = params['query'][0]
            else query = params['query']
            end
            @groups = Group.user_query(query).is_public # Scope che cerca sia nel nome, che nel corso di un gruppo
        else
            @groups = current_user.suggested_groups # Scope che restituisce 10 - 12 gruppi che potrebbero
                                                    # interessare all'utente loggato
        end

        render "index"
    end

    # GET group_path(uuid: group.uuid)
    def show
        # Visualizza la chat di un gruppo, inclusi messaggi, eventi e membri (online ed offline)
        # Scope che definisce di cercare solo i messaggi più recenti
        @messages = @group.messages.recent
        @pinned_messages = @group.messages.pinned
        set_last_message_read(@group, DateTime.now)

        # Carica solo gli eventi della settimana
        @events = @group.events.next
        @memberships = @group.memberships

        render file: "app/views/groups/show"
    end

    # GET new_group_path
    def new
        # Visualizza la form per creare un nuovo gruppo
        @group = Group.new
        render "new"
    end

    # POST groups_path
    def create
        # Salva il gruppo inviato nel DB
        @group = Group.new(group_params)

        if @group.save_with_admin(current_user)
            # Faccio il reload del gruppo per aggiornare il suo uuid
            @group.reload
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now[:error] = 'Le informazioni inserite non sono valide'
            render "new"
        end
    end

    # GET edit_group_path(uuid: group.uuid)
    def edit
        # Visualizza la form per modificare un nuovo gruppo
        render "edit"
    end

    # PUT/PATCH group_path(uuid: group.uuid)
    def update
        # Aggiorna le informazioni sul gruppo
        if @group.update(group_params)
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now[:error] = 'Le informazioni del gruppo non sono state aggiornate'
            render "edit"
        end
    end

    # DELETE group_path(uuid: group.uuid)
    def destroy
        # Cancella un gruppo, compresi tutti i messaggi e gli eventi, nonché le relazioni
        # con le altre tabelle (inviti, membri)
        @group.destroy

        puts "Ciao"
        flash[:success] = "Il gruppo è stato cancellato"
        redirect_to groups_path
    end

    private
    def set_group
        begin
            @group = Group.find_by_uuid(params[:uuid]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end

    def group_params
        params.require(:group).permit(:name, :max_members, :private, :course_id, :description)
    end

    def set_degrees
        @degrees = Degree.all
    end
end
