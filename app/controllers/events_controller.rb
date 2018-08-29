class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :set_group
    before_action :logged_in_user
    before_action only: [:user_index, :show] do
        correct_user params[:user_id]
    end
    before_action only: [:index] do
        is_member_in @group
    end
    before_action only: [:new, :create, :edit, :update, :destroy] do
        is_admin_in @group
    end

    # GET group_events_path(group_uuid: group.uuid)
    def index
        # Visualizza tutti gli eventi di un gruppo
        # Uso il parametro 'from' per stabilire da quando devo recuperare gli eventi
        # Si segua il formato della stringa che si ottiene da un valore di tipo DateTime
        if params['from'].nil?
            @events = @group.events.next
        else
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['from'].is_a? Array
                from = params['from'][0]
            else from = params['from']
            end
            from = from.to_datetime
            @events = @group.events.next(from)
        end
        
        render json: @events
    end


    # GET user_events_path(user)
    def user_index
        # Visualizza tutti gli eventi dei gruppi di cui fa parte l'utente
        @events = @user.events.next
        render json: @events
    end

    # GET user_event_path(user, event)
    def show
        # Mostra la descrizione di un evento (magari su una finestrella)
        render json: @event
    end

    # GET new_group_event_path(group_uuid: group.uuid)
    def new
        # Mostra la form per creare un evento
        @event = Event.new
        render json: @event
    end

    # POST group_events_path(group_uuid: group.uuid)
    def create
        # Salva nel db un nuovo evento
        @event = Event.new(event_params)

        if @event.save
            redirect_to group_events_path(group_uuid: @group.uuid)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono valide'
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
        end
    end

    # GET edit_group_event_path(group_uuid: group.uuid, id: event.id)
    def edit
        # Mostra la form per modificare un evento
        render json: @event
    end

    # PUT/PATCH group_event_path(group_uuid: group.uuid, id: event.id)
    def update
        # Salva nel db le modifiche ad un evento
        if @event.update(event_params)
            redirect_to group_events_path(group_uuid: @group.uuid)
        else
            flash.now[:danger] = "Le informazioni dell'evento non sono state aggiornate"
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine            
        end
    end

    # DELETE group_event_path(group_uuid: group.uuid, id: event.id)
    def destroy
        # Elimina un evento
        @event.destroy

        redirect_to group_events_path(group_uuid: @group.uuid)
    end

    private
    def set_event
        @event = Event.find(params[:id])
    end

    def set_group
        @group = Group.find_by_uuid(params[:group_uuid])
    end

    def event_params
      params.require(:event).permit(:start_time, :end_time, :place, :description, :group_id)
    end
end
