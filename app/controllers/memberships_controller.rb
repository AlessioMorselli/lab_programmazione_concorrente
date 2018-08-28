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
  before_action only: [:destroy], unless: -> {@user == current_user} do
    is_admin_in @group
  end
  before_action only: [:destroy], if: -> {@group.admins.include? @user} do
    flash[:danger] = "L'utente selezionato è un amministratore e non può essere rimosso"
    redirect_to group_path(uuid: @group.uuid)
  end
  before_action only: [:set_admin, :set_super_admin] do
    is_super_admin_in @group
  end

  # GET group_memberships(group_uuid: group.uuid)
  def index
    # Recupera tutti i membri di un gruppo, in modo da poter visualizzare chi fa parte di un gruppo
    # e chi è online in quel momento (forse, adesso vediamo)
    @members = @group.memberships

    render json: @members
  end

  # DELETE group_memberships(group_uuid: group.uuid, user_id: user.id)
  def destroy
    # Toglie un utente da un gruppo
    @group.members.delete(@user)
    # Cancella anche il cookie dell'utente associato al gruppo
    cookies.delete(create_last_message_key(@user, @group))

    if !@group.members.include? current_user
      redirect_to groups_path
    else
      flash[:success] = "Membro eliminato dal gruppo"
      redirect_to group_path(uuid: @group.uuid)
    end
  end

  # PUT/PATCH group_set_admin_path(group_uuid: group.uuid, user_id: user.id)
  def set_admin
    # Rende un utente amministratore e gli rimuove il titolo, se lo è già
    @membership.admin = !@membership.admin

    if @membership.save
      flash[:success] = "L'utente #{@user.name} è stato " +
      (@membership.admin ? "aggiunto agli" : "tolto dagli") +
      " amministratori del gruppo."
    else
      flash[:danger] = "L'utente #{@user.name} non è stato " +
      (@membership.admin ? "aggiunto agli" : "tolto dagli") +
      " amministratori del gruppo."
    end

    redirect_to group_path(uuid: @group.uuid)
  end

  # PUT/PATCH group_set_super_admin_path(group_uuid: group.uuid, user_id: user.id)
  def set_super_admin
    # Trasferisce il titolo di super admin dal super admin attuale ad un altro membro del gruppo
    if @group.change_super_admin(@user)
      flash[:success] = "Il regno di #{@user.name} ha inizio, dopo l'abdicazione di #{current_user.name}"
    else
      flash[:danger] = "L'utente #{@user.name} non è stato nominato super amministratore. Ritenta."
    end

    redirect_to group_path(uuid: @group.uuid)
  end

  private
  def set_membership
    @user = User.find(params[:user_id])
    @membership = Membership.get_one(@user, @group)
  end

  def set_group
    @group = Group.find_by_uuid(params[:group_uuid])
  end

  def membership_params
    params.require(:membership).permit(:group_id, :user_id)
  end
end
