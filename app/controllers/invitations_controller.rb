class InvitationsController < ApplicationController
    before_action :set_invitation, only: [:show, :edit, :update, :destroy, :accept, :refuse]

    # GET user_invitations_path(user)
    def index
        # Visualizza tutte gli inviti in sospeso da parte di un utente
        @invitations = current_user.invitations
        render json: @invitations
    end

    # GET group_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def show
        # Mostra 2 scelte all'utente: accetta e rifiuta, rispettivamente 
        # corrispondenti alle azioni accept e refuse
        render json: @invitation
    end

    # GET new_group_invitation_path(group_uuid: group.uuid)
    def new
        # Visualizza la form per invitare un utente ad un gruppo
        @invitation = Invitation.new
        render json: @invitation
    end

    # POST group_invitations_path(group_uuid: group.uuid)
    def create
        # Salva l'invito nel db
        @invitation = Invitation.new(invitation_params)
        if @invitation.save!
            redirect_to group_path(uuid: @invitation.group.uuid)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono corrette'
            render 'new'
        end
    end

    # DELETE group_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def destroy
        # Un amministratore del gruppo cancella l'invito (il link non sarà quindi più valido)
        @invitation.destroy
    end

    # GET group_accept_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def accept
        # L'utente a cui è stato inviato l'invito ha accettato
        # L'azione ha quindi 2 effetti:
        #   - l'utente è aggiunto come membro del gruppo
        #   - l'invito perde di validità (se è destinato ad un utente specifico)
        @group = @invitation.group

        if @invitation.accept(current_user)
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now(:danger) = "Qualcosa è andato storto e l'invito non è andato a buon fine!"
        end
    end

    # GET group_refuse_invitation_path(group_uuid: group.uuid, url_string: @invitation.url_string)
    def refuse
        # L'utente a cui è stato inviato l'invito ha rifiutato
        # L'azione ha quindi un solo effetto:
        #   - l'invito perde di validità (se è destinato ad un utente specifico)
        if !@invitation.user_id.nil?
            @invitation.destroy
        end

        redirect_to groups_path
    end

    private
    def set_invitation
        @invitation = Invitation.find(params[:id])
    end

    def invitation_params
        params.require(:invitation).permit(:user_id, :group_id, :expiration_date)
    end
end
