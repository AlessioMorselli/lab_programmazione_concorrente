class MessagesController < ApplicationController
    before_action :set_message, only: [:edit, :update, :destroy, :pin_message]
    before_action :logged_in_user, except: [:index]
    before_action only: [:update] do
        correct_user @message.user_id
    end
    before_action only: [:destroy], unless: -> {@message.group.admins.include? current_user} do
        correct_user @message.user_id
    end
    before_action :set_group
    before_action do
        is_member_in @group if current_user
    end 
    before_action only: [:destroy], unless: -> {current_user? @message.user} do
        is_admin_in @group
    end
    before_action only: [:pin_message] do
        is_admin_in @group
    end

    # GET group_messages_path(group_uuid: group.uuid)
    def index
      if logged_in?
        # Restituisce tutti i messaggi del gruppo, a partire da una certa data e ora
        # Uso il parametro 'from' per stabilire da quando devo recuperare i messaggi
        # Si segua il formato della stringa che si ottiene da un valore di tipo DateTime
        if params['from'].nil?
            @messages = @group.messages.recent(get_last_message_read(@group)).without_user(current_user)
        else
            # Controllo che non sia un array! Mi serve un solo parametro
            if params['from'].is_a? Array
                from = params['from'][0]
            else from = params['from']
            end
            from = from.to_datetime
            @messages = @group.messages.recent(from).without_user(current_user)
        end
        
        set_last_message_read(@group, DateTime.now)

        respond_to do |format|
            format.html { render partial: 'messages/index', locals: {messages: @messages, group: @group} }
        end
      else
        respond_to do |format|
          format.json { render :json => { :error => 'Non sei loggato! non puoi accedere ai messaggi' }, status: 403 }
        end
      end
    end

    # POST group_messages_path(group_uuid: group.uuid)
    def create
        # Il messaggio viene salvato nel db e visualizzato sulla chat
        @message = Message.new(message_params)
        @message.group = @group
        @message.user = current_user
        if !attachment_params[:attachment].blank?
            incoming_file = attachment_params[:attachment]
            @attachment = Attachment.new
            @attachment.name = incoming_file.original_filename
            @attachment.mime_type = incoming_file.content_type
            @attachment.data = incoming_file.read
        end

        respond_to do |format|
            if @message.save_with_attachment(@attachment)
                format.html { render partial: 'messages/show', locals: {message: @message, group: @group} }
            else
                format.json { render :json => { :error => 'Il messaggio non è stato inviato' }, status: 422 }
                #flash.now[:error] = 'Il messaggio non è stato inviato'
            end
        end
    end

    # PUT/PATCH group_message_path(group_uuid: group.uuid, id: message.id)
    def update
        # Modifica il testo di un messaggio
        if !@message.update(message_params)
            flash.now[:error] = 'Il messaggio non è stato modificato'
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
        @pinned_messages = @group.messages.pinned

        render json: @pinned_messages
    end

    # PUT/PATCH group_pin_message(group_uuid: group.uuid, id: message.id)
    def pin_message
        # Aggiunge un messaggio in bacheca o lo toglie, se già presente
        @message.pinned = !@message.pinned
        if @message.save
            flash.now[:success] = "Il messaggio è stato " +
                (@message.pinned ? "aggiunto alla" : "tolto dalla") +
                " bacheca."
        else flash.now[:error] = "Il messaggio non è stato " +
            (@message.pinned ? "aggiunto alla" : "tolto dalla") +
            " bacheca."
        end

        render json: @message
    end

    private
    def set_message
        begin
            @message = Message.find(params[:id]) or not_found
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

    def message_params
        params.require(:message).permit(:text)
    end

    def attachment_params
        params.require(:message).permit(:attachment)
    end
end
