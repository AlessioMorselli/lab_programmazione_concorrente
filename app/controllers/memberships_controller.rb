class MembershipsController < ApplicationController
  before_action :set_group
  before_action :set_membership, only: [:destroy, :set_admin, :set_super_admin]
  before_action :logged_in_user
  before_action only: [:destroy], unless: -> {@group.admins.include? current_user} do
    correct_user params[:user_id]
  end
  before_action only: [:index, :destroy] do
    is_member_in @group
  end
  before_action only: [:destroy], unless: -> {current_user? @user} do
    is_admin_in @group
  end
  before_action only: [:destroy], if: -> {@group.admins.include? @user} do
    flash[:error] = "L'utente selezionato è un amministratore e non può essere rimosso"
    redirect_to group_path(uuid: @group.uuid)
  end
  before_action only: [:set_admin, :set_super_admin] do
    is_super_admin_in @group
  end

  # GET group_memberships_path(group_uuid: group.uuid)
  def index
    # Recupera tutti i membri di un gruppo, in modo da poter visualizzare chi fa parte di un gruppo
    # e chi è online in quel momento (forse, adesso vediamo)
    @members = @group.memberships

    render file: "app/views/memberships/index"
  end

  # POST group_memberships_path(group_uuid: group.uuid)
  def create
    # Il link viene usato in ingresso ad un gruppo pubblico di cui non si è membri
    if !@group.members.include? current_user
      @membership = Membership.new(group: @group, user: current_user)
      if @membership.save
        flash[:success] = "Benvenuto nel gruppo " + @group.name + "!"
        redirect_to group_path(uuid: @group.uuid)
      else
        flash[:error] = "Qualcosa è andato storto e non siamo riusciti a farti accedere al gruppo " + @group.name
        redirect_to groups_path
      end
    else
      redirect_to group_path(uuid: @group.uuid)
    end
  end

  # DELETE group_membership_path(group_uuid: group.uuid, user_id: user.id)
  def destroy
    # Toglie un utente da un gruppo
    @group.members.delete(@user)
    # Cancella anche il cookie dell'utente associato al gruppo
    cookies.delete(create_last_message_key(@user, @group))

    if !@group.members.include? current_user
      # Se non abbandono il gruppo dalla dashboard dello stesso, ridireziono verso l'ultima richiesta...
      unless request.referrer == group_url(uuid: @group.uuid)
        redirect_back(fallback_location: groups_path)
      # Altrimenti ridireziono verso la lista di gruppi suggeriti
      else
        redirect_to groups_path
      end
    else
      flash[:success] = "Membro eliminato dal gruppo"
      redirect_to group_path(uuid: @group.uuid)
    end
  end

  # PATCH group_set_admin_path(group_uuid: group.uuid, user_id: user.id)
  def set_admin
    # Rende un utente amministratore e gli rimuove il titolo, se lo è già
    @membership.admin = !@membership.admin

    if @membership.save
      flash[:success] = "L'utente #{@user.name} è stato " +
      (@membership.admin ? "aggiunto agli" : "tolto dagli") +
      " amministratori del gruppo."
    else
      flash[:error] = "L'utente #{@user.name} non è stato " +
      (@membership.admin ? "aggiunto agli" : "tolto dagli") +
      " amministratori del gruppo."
    end

    redirect_to group_path(uuid: @group.uuid)
  end

  # PATCH group_set_super_admin_path(group_uuid: group.uuid, user_id: user.id)
  def set_super_admin
    # Trasferisce il titolo di super admin dal super admin attuale ad un altro membro del gruppo
    if @group.change_super_admin(@user)
      flash[:success] = "Il regno di #{@user.name} ha inizio, dopo l'abdicazione di #{current_user.name}"
    else
      flash[:error] = "L'utente #{@user.name} non è stato nominato super amministratore. Ritenta."
    end

    redirect_to group_path(uuid: @group.uuid)
  end

  private
  def set_membership
    begin
      @user = User.find(params[:user_id]) or not_found
      @membership = Membership.get_one(@user, @group) or not_found
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

  def membership_params
    params.require(:membership).permit(:group_id, :user_id)
  end
end
