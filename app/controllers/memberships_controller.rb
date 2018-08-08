class MembershipsController < ApplicationController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  # GET group_memberships(group)
  def index
    # Recupera tutti i membri di un gruppo, in modo da poter visualizzare chi fa parte di un gruppo
    # e chi è online in quel momento (forse, adesso vediamo)
    group = Group.find(params[:group_id])
    @members = group.memberships
  end

  # DELETE group_memberships(group, membership)
  def destroy
    # Toglie un utente da un gruppo
    @membership.destroy
    redirect_to groups_path
  end

  private
  def set_memberships
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:group_id, :user_id, :admin)
  end
end
