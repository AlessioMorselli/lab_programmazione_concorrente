class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :edit, :update, :destroy]

    # GET group_messages_path(group)
    def index
        # Restituisce tutti i messaggi del gruppo, a partire da una certa data e ora
        group = Group.find(params[:group_id])
        @messages = group.messages.recent
    end

    # POST group_messages_path(group)
    def create
        # Il messaggio viene salvato nel db e visualizzato sulla chat
        @message = Message.new(message_params)
        if !@message.save
            flash.now[:danger] = 'Il messaggio non è stato inviato'
        end
    end

    # PUT/PATCH group_message_path(group, message)
    def update
        # Modifica il testo di un messaggio
        if !@message.update(message_params)
            flash.now[:danger] = 'Il messaggio non è stato modificato'
        end
    end

    # DELETE group_message_path(group, message)
    def destroy
        # Cancella un messaggio dalla chat del gruppo
        @message.destroy
        flash.now[:success] = 'Il messaggio è stato eliminato'
    end

    # GET group_pinned_messages(group)
    def pinned
        # Visualizza i messaggi pinnati di un gruppo
        group = Group.find(params[:group_id])
        @pinned_messages = group.pinned_messages
    end

    private
    def set_message
        group = Group.find(params[:group_id])
        @message = Message.get_one(group, current_user)
    end

    def message_params
        params.require(:message).permit(:text, :attachement, :pinned, :group_id, :user_id)
    end
end
