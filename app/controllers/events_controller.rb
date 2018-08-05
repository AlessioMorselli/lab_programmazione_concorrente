class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    # GET group_events_path(group)
    # GET user_events_path(user)
    # DOMANDA: meglio fare due funzioni diverse del tipo group_index e user_index? --> può essere, adesso vedo
    def index
        # INNESTATO A GROUP: tutti gli eventi di un gruppo
        # INNESTATO A USER: tutti gli eventi dei gruppi di un utente
    end

    # GET user_event_path(user, event)
    def show
        # Mostra la descrizione di un evento (magari su una finestrella)
    end

    # GET new_group_event_path(group)
    def new
        # Mostra la form per creare un evento
    end

    # POST group_events_path(group)
    def create
        # Salva nel db un nuovo evento
    end

    # GET edit_group_event_path(group)
    def edit
        # Mostra la form per modificare un evento
    end

    # PUT/PATCH group_event_path(group, event)
    def update
        # Salva nel db le modifiche ad un evento
    end

    # DELETE group_event_path(group, event)
    def destroy
        # Elimina un evento
    end

    private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:start_time, :end_time, :place, :description, :groupo_id)
    end
end
