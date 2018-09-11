class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :set_group, except: [:user_index]
    before_action :logged_in_user
    before_action only: [:user_index] do
        correct_user params[:user_id]
    end
    before_action only: [:index, :show] do
        is_member_in @group
    end
    before_action only: [:new, :create, :edit, :update, :destroy] do
        is_admin_in @group
    end

    # GET group_events_path(group_uuid: group.uuid)
    def index
        # Visualizza tutti gli eventi di un gruppo
        # Uso il parametro 'up_to' per stabilire da quando devo recuperare gli eventi
        # Esempio di parametro valido: (2.months).to_s
        if params['up_to'].nil?
            @events = @group.events.next
        else
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['up_to'].is_a? Array
                up_to = params['up_to'][0]
            else up_to = params['up_to']
            end
            up_to = up_to.to_i
            @events = @group.events.next(up_to)
        end
        
        render json: @events
    end


    # GET user_events_path(user)
    def user_index
        # Visualizza tutti gli eventi dei gruppi di cui fa parte l'utente
        # Uso il parametro 'up_to' per stabilire da quando devo recuperare gli eventi
        # Esempio di parametro valido: (2.months).to_s
        if params['up_to'].nil?
            @events = @user.events.next
        else
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['up_to'].is_a? Array
                up_to = params['up_to'][0]
            else up_to = params['up_to']
            end
            up_to = up_to.to_i
            @events = @user.events.next(up_to)
        end
        
        render json: @events
    end

    # GET group_event_path(group_uuid: group.uuid, id: event.id)
    def show
        # Mostra la descrizione di un evento (magari su una finestrella)
        render json: @event
    end

    # GET new_group_event_path(group_uuid: group.uuid)
    def new
        # Mostra la form per creare un evento
        @event = Event.new
        render file: 'app/views/dashboard_new_event'
    end

    # POST group_events_path(group_uuid: group.uuid)
    def create
        # Salva nel db un nuovo evento
        @event = Event.new(event_params)
        @event.repeated = params[:event][:repeated].to_i
        @event.repeated_for = params[:event][:repeated_for].to_i

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
        begin
            @event = Event.find(params[:id]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end

    def set_group
        begin
            @group = Group.find_by_uuid(params[:group_uuid]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end

    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :place, :description, :group_id)
    end
end
