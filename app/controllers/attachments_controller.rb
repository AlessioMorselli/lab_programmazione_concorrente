class AttachmentsController < ApplicationController
    before_action :set_attachment, only: [:show, :edit, :update, :destroy, :download_attachment]

    # DELETE group_message_attachment(group_uuid: group.uuid, message_id: message.id, id: attachment.id)
    def destroy
        # Cancella l'allegato di un messaggio, senza cancellare il messaggio per intero
        @group = Group.find_by_uuid(params[:uuid])
        @attachment.destroy
        flash.now[:success] = "L'allegato è stato eliminato"
        redirect_to group_path(group_uuid: @group.uuid)
    end

    # GET group_message_attachment_download_path(group_uuid: group.uuid, message_id: message.id, id: attachment.id)
    def download_attachment
        # Restituisce, in download, l'allegato del messaggio selezionato
        send_data @attachment.data, filename: @attachment.name, type: @attachment.type, disposition: 'attachment'
    end

    private
    def set_attachment
        @attachment = Attachment.find(params[:id])
    end

    def attachment_params
        params.require(:attachment).permit(:name, :type, :data)
    end
end
