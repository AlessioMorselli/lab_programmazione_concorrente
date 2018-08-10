class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    # GET group_events_path(group_uuid: group.uuid)
    def index
        # Visualizza tutti gli eventi di un gruppo
        group = Group.find_by_uuid(params[:group_uuid])
        @events = group.events#.this_month
        render json: @events
    end


    # GET user_events_path(user)
    def user_index
        # Visualizza tutti gli eventi dei gruppi di cui fa parte l'utente
        @events = current_user.groups.events#.this_month
        render json: @events
    end

    # GET user_event_path(user, event)
    def show
        # Mostra la descrizione di un evento (magari su una finestrella)
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
            redirect_to group_path(uuid: @event.group.uuid)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono valide'
            render 'new'
        end
    end

    # GET edit_group_event_path(group_uuid: group.uuid, event)
    def edit
        # Mostra la form per modificare un evento
    end

    # PUT/PATCH group_event_path(group_uuid: group.uuid, event)
    def update
        # Salva nel db le modifiche ad un evento
        if @event.update(event_params)
            redirect_to group_path(uuid: @event.group.uuid)
        else
            flash.now[:danger] = "Le informazioni dell'evento non sono state aggiornate"
            render 'edit'
        end
    end

    # DELETE group_event_path(group_uuid: group.uuid, event)
    def destroy
        # Elimina un evento
        group = @event.group
        @event.destroy

        redirect_to group_path(uuid: group.uuid)
    end

    private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:start_time, :end_time, :place, :description, :groupo_id)
    end
end
