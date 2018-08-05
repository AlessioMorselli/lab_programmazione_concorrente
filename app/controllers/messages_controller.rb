class MessagesController < ApplicationController
    before_action :set_message, only: [:update, :destroy]

    # GET group_messages_path(group)
    def index
        # Restituisce tutti i messaggi del gruppo, a partire da una certa data e ora
    end

    # POST group_messages_path(group)
    def create
        # Il messaggio viene salvato nel db ed visualizzato sulla chat
    end

    # PUT/PATCH group_message_path(group, message)
    def update
        # Modifica il testo di un messaggio
    end

    # DELETE group_message_path(group, message)
    def destroy
        # Cancella un messaggio dalla chat del grupp
    end

    private
    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:text, :attachement, :pinned, :group_id, :user_id)
    end
end
