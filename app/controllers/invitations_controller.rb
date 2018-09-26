class InvitationsController < ApplicationController
    layout "main"
    before_action :set_invitation, only: [:destroy, :accept, :refuse]
    before_action :set_group, only: [:index, :new, :create, :destroy, :accept], unless: -> {params[:group_uuid].nil?}
    before_action :set_user, only: [:create]
    before_action :is_member, only: [:create]
    before_action :logged_in_user
    before_action only: [:index] do
        correct_user params[:user_id] unless params[:user_id].nil?
    end
    before_action only: [:index, :new, :create, :destroy], unless: -> {params[:group_uuid].nil?} do
        is_admin_in @group
    end

    # GET user_invitations_path(user)
    # GET group_invitations_path(group_uuid: group.uuid)
    def index
        if params[:user_id]
            # Visualizza tutte gli inviti in sospeso da parte di un utente
            @invitations = @user.invitations.not_expired
            render "index"
        elsif params[:group_uuid]
            # Lista degli inviti di un gruppo
            @invitations = @group.invitations
            render "group_index"
        end
    end

    # GET new_group_invitation_path(group_uuid: group.uuid)
    def new
        # Visualizza la form per invitare un utente ad un gruppo
        @invitation = Invitation.new
        render "new"
    end

    # POST group_invitations_path(group_uuid: group.uuid)
    def create
        # Salva l'invito nel db
        @invitation = Invitation.new(invitation_params)
        @invitation.group = @group
        @invitation.user = @user
        if @invitation.save
            flash[:success] = 'Invito creato!'
            @invitation.reload
            InvitationMailer.invite_to_group(@invitation).deliver_now if @invitation.is_private?
            redirect_to group_invitations_path(group_uuid: @group.uuid)
        else
            if @user && Invitation.find_by_user_id(@user.id)
                flash.now[:error] = "L'utente #{@user.name} è già stato invitato!"
            else
                flash.now[:error] = 'Le informazioni inserite non sono corrette'
            end
            render "new"
        end
    end

    # DELETE group_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def destroy
        # Un amministratore del gruppo cancella l'invito (il link non sarà quindi più valido)
        @invitation.destroy
        flash[:success] = "Invito cancellato"
        redirect_to group_invitations_path(group_uuid: @group.uuid)
    end

    # GET group_accept_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def accept
        # L'utente a cui è stato inviato l'invito ha accettato
        # L'azione ha quindi 2 effetti:
        #   - l'utente è aggiunto come membro del gruppo
        #   - l'invito perde di validità (se è destinato ad un utente specifico)

        if @invitation.accept(current_user)
            # Quando un utente si aggiunge ad un gruppo, setto l'ultimo messaggio letto a quelli
            # del giorno precedente
            set_last_message_read(@group, DateTime.now - 1.days)
            redirect_to group_path(uuid: @group.uuid)
        else
            flash.now[:error] = "Qualcosa è andato storto e l'invito non è andato a buon fine!"
            # TODO: che faccio se c'è qualcosa che non va? Devo testare meglio quando saranno presenti le pagine
            redirect_to groups_path
        end
    end

    # GET group_refuse_invitation_path(group_uuid: group.uuid, url_string: invitation.url_string)
    def refuse
        # L'utente a cui è stato inviato l'invito ha rifiutato
        # L'azione ha quindi un solo effetto:
        #   - l'invito perde di validità (se è destinato ad un utente specifico)
        if !(@invitation.user.nil?)
            @invitation.destroy
        end

        redirect_to groups_path
    end

    private
    def set_invitation
        begin
            @invitation = Invitation.find_by_url_string(params[:url_string]) or not_found
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

    def set_user
        if params[:invitation][:user].blank?
            @user = nil
        elsif
            unless @user = User.find_by_email_or_name(params[:invitation][:user])
                flash[:error] = "L'utente indicato non esiste"
                redirect_to new_group_invitation_path(group_uuid: @group.uuid)
            end
        end
    end

    def is_member
        if @group.members.include? @user
            flash[:danger] = "L'utente è già presente nel gruppo!"
            redirect_to new_group_invitation_path(group_uuid: @group.uuid)
        end
    end

    def invitation_params
        params.require(:invitation).permit(:expiration_date)
    end
end
