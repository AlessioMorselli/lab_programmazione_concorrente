class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    # GET group_events_path(group)
    def index
        # Visualizza tutti gli eventi di un gruppo
        group = Group.find(params[:group_id])
        @events = group.events.this_month
    end


    # GET user_events_path(user)
    def user_index
        # Visualizza tutti gli eventi dei gruppi di cui fa parte l'utente
        @events = current_user.groups.events.this_month
    end

    # GET user_event_path(user, event)
    def show
        # Mostra la descrizione di un evento (magari su una finestrella)
    end

    # GET new_group_event_path(group)
    def new
        # Mostra la form per creare un evento
        @event = Event.new
    end

    # POST group_events_path(group)
    def create
        # Salva nel db un nuovo evento
        @event = Event.new(event_params)

        if event.save
            redirect_to group_path(@event.group)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono valide'
            render 'new'
        end
    end

    # GET edit_group_event_path(group)
    def edit
        # Mostra la form per modificare un evento
    end

    # PUT/PATCH group_event_path(group, event)
    def update
        # Salva nel db le modifiche ad un evento
        if @event.update(event_params)
            redirect_to group_path(@event.group)
        else
            flash.now[:danger] = "Le informazioni dell'evento non sono state aggiornate"
            render 'edit'
        end
    end

    # DELETE group_event_path(group, event)
    def destroy
        # Elimina un evento
        group = @event.group
        @event.destroy

        redirect_to group_path(group)
    end

    private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:start_time, :end_time, :place, :description, :groupo_id)
    end
end
