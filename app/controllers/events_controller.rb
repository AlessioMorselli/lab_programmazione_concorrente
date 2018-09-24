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
        # Per restituire tutti gli eventi, passare un params 'all'
        if !params['all'].nil?
            @events = @group.events.next(100.years)
        # Uso il parametro 'up_to' per stabilire da quando devo recuperare gli eventi
        # Esempio di parametro valido: (2.months).to_s
        elsif params['up_to'].nil?
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
        
        respond_to do |format|
            format.html { 
                render partial: 'events/index', locals: {events: @events, group: @group}
            }
        end

        # render json: @events
    end


    # GET user_events_path(user)
    def user_index
        # Visualizza tutti gli eventi dei gruppi di cui fa parte l'utente
        # Per restituire tutti gli eventi, passare un params 'all'
        if !params['all'].nil?
            @events = @user.events.next(100.years)
        # Uso il parametro 'up_to' per stabilire da quando devo recuperare gli eventi
        # Esempio di parametro valido: (2.months).to_s
        elsif params['up_to'].nil?
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

        respond_to do |format|
            format.html { render partial: 'events/index', locals: {events: @events, user: @user} }
        end
        
        # render json: @events
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
        render "new"
    end

    # POST group_events_path(group_uuid: group.uuid)
    def create
        # Salva nel db un nuovo evento
        @event = Event.new(event_params)
        @event.repeated = params[:event][:repeated].to_i.days
        @event.repeated_for = params[:event][:repeated_for].to_i

        if @event.save
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now[:error] = 'Le informazioni inserite non sono valide'
            render "new"
        end
    end

    # GET edit_group_event_path(group_uuid: group.uuid, id: event.id)
    def edit
        # Mostra la form per modificare un evento
        render "edit"
    end

    # PUT/PATCH group_event_path(group_uuid: group.uuid, id: event.id)
    def update
        # Salva nel db le modifiche ad un evento
        if @event.update(event_params)
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now[:error] = "Le informazioni dell'evento non sono state aggiornate"
            render "edit"            
        end
    end

    # DELETE group_event_path(group_uuid: group.uuid, id: event.id)
    def destroy
        # Elimina un evento
        @event.destroy

        redirect_to group_path(uuid: @group.uuid)
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
