class AttachmentsController < ApplicationController
    before_action :set_group
    before_action :set_message
    before_action :set_attachment
    before_action :logged_in_user
    before_action do
        is_member_in @group
    end

    # GET group_message_attachment_download_path(group_uuid: group.uuid, message_id: message.id, id: attachment.id)
    def download_attachment
        # Restituisce, in download, l'allegato del messaggio selezionato
        send_data @attachment.data, filename: @attachment.name, type: @attachment.mime_type, disposition: 'attachment'
    end

    private
    def set_attachment
        begin
            @attachment = Attachment.find(params[:id]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end

    def set_message
        begin
            @message = Message.find(params[:message_id]) or not_found
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

    def attachment_params
        params.require(:attachment).permit(:name, :mime_type, :data)
    end
end
