class InvitationsController < ApplicationController
    before_action :set_invitation, only: [:show, :edit, :update, :destroy]

    # GET user_invitations_path(user)
    def index
        # Visualizza tutte gli inviti in sospeso da parte di un utente
        @invitations = current_user.invitations
    end

    # GET new_group_invitation_path(group)
    def new
        # Visualizza la form per invitare un utente ad un gruppo
        @invitation = Invitation.new
    end

    # POST group_invitations_path(group)
    def create
        # Salva l'invito nel db
        @invitation = Invitation.new(invitation_params)
        if @invitation.save
            redirect_to group_path(@invitation.group)
        else
            flash.now[:danger] = 'Le informazioni inserite non sono corrette'
            render 'new'
        end
    end

    # DELETE group_invitation_path(group, invitation)
    def destroy
        # Cancella un invito ed esegue una delle due seguenti azioni:
        #   - se l'utente risponde affermativamente, viene aggiunto al gruppo
        #   - altrimenti, viene solo cancellato l'invito, senza alcun effetto aggiuntivo
        # Il secondo caso avviene anche se è un amministratore del gruppo a cancellarlo
        
    end

    private
    def set_invitation
        group = Group.find(params[:group_id])
        @invitation = Invitation.get_one(group, current_user)
    end

    def invitation_params
        params.require(:invitation).permit(:user_id, :group_id)
    end
end
