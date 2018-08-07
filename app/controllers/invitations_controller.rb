class InvitationsController < ApplicationController
    before_action :set_invitation, only: [:destroy]

    # GET user_invitations_path(user)
    def index
        # Visualizza tutte gli inviti in sospeso da parte di un utente
    end

    # GET new_group_invitation_path(group)
    def new
        # Visualizza la form per invitare un utente ad un gruppo
    end

    # POST group_invitations_path(group)
    def create
        # Salva l'invito nel db
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
      @invitation = Invitation.find(params[:id])
    end

    def group_params
      params.require(:invitation).permit(:user_id, :group_id)
    end
end
