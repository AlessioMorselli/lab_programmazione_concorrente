class AttachmentsController < ApplicationController
    before_action :set_group
    before_action :set_message
    before_action :set_attachment
    before_action :logged_in_user
    before_action only: [:destroy], unless: -> {@group.admins.include? current_user} do
        correct_user @message.user_id
    end
    before_action do
        is_member_in @group
    end
    before_action only: [:destroy], unless: -> {@message.user == current_user} do
        is_admin_in @group
    end

    # DELETE group_message_attachment_path(group_uuid: group.uuid, message_id: message.id, id: attachment.id)
    def destroy
        # Cancella l'allegato di un messaggio, senza cancellare il messaggio per intero
        if @message.destroy_attachment
            flash[:success] = "L'allegato è stato eliminato"
        else
            flash[:danger] = "L'allegato non è stato eliminato"
        end
        redirect_to group_path(uuid: @group.uuid)
    end

    # GET group_message_attachment_download_path(group_uuid: group.uuid, message_id: message.id, id: attachment.id)
    def download_attachment
        # Restituisce, in download, l'allegato del messaggio selezionato
        send_data @attachment.data, filename: @attachment.name, type: @attachment.mime_type, disposition: 'attachment'
    end

    private
    def set_attachment
        @attachment = Attachment.find(params[:id])
    end

    def set_message
        @message = Message.find(params[:message_id])
    end

    def set_group
        @group = Group.find_by_uuid(params[:group_uuid])
    end

    def attachment_params
        params.require(:attachment).permit(:name, :mime_type, :data)
    end
end
