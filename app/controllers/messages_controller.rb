class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :edit, :update, :destroy, :download_attachment]

    # GET group_messages_path(group_uuid: group.uuid)
    def index
        # Restituisce tutti i messaggi del gruppo, a partire da una certa data e ora
        @group = Group.find_by_uuid(params[:group_uuid])

        # Uso il parametro 'from' per stabilire da quando devo recuperare i messaggi
        # Si segua il formato della stringa che si ottiene da un valore di tipo DateTime
        if params['from'].nil?
            @messages = @group.messages.recent(get_last_message_read(@group))
        else
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['from'].is_a?
                from = params['from'][0]
            else from = params['from']
            end
            from = from.to_datetime
            @messages = @group.messages.recent(from)
        end
        
        set_last_message_read(@group, DateTime.now)

        render json: @messages
    end

    # POST group_messages_path(group_uuid: group.uuid)
    def create
        # Il messaggio viene salvato nel db e visualizzato sulla chat
        @message = Message.new(message_params)
        @attachment = (attachment_params[:name].nil? ? nil : Attachment.new(attachment_params))
        if !@message.save_with_attachment(@attachment)
            flash.now[:danger] = 'Il messaggio non è stato inviato'
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
        end

    end

    # PUT/PATCH group_message_path(group_uuid: group.uuid, id: message.id)
    def update
        # Modifica il testo di un messaggio
        if !@message.update(message_params)
            flash.now[:danger] = 'Il messaggio non è stato modificato'
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
        end
    end

    # DELETE group_message_path(group_uuid: group.uuid, id: message.id)
    def destroy
        # Cancella un messaggio dalla chat del gruppo
        @message.destroy
        flash.now[:success] = 'Il messaggio è stato eliminato'
    end

    # GET group_pinned_messages(group_uuid: group.uuid)
    def pinned
        # Visualizza i messaggi pinnati di un gruppo
        @group = Group.find_by_uuid(params[:group_uuid])
        @pinned_messages = @group.messages.pinned

        render json: @pinned_messages
    end

    private
    def set_message
        @message = Message.find(params[:id])
    end

    def message_params
        params.require(:message).permit(:text, :attachment_id, :pinned, :group_id, :user_id)
    end

    def attachment_params
        params.require(:attachment).permit(:name, :mime_type, :data)
    end
end
