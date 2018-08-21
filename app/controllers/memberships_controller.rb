class MembershipsController < ApplicationController
  before_action :set_group
  before_action :set_membership, only: [:destroy]
  before_action :logged_in_user
  before_action only: [:destroy], unless: -> {@membership.admin} do
    correct_user params[:user_id]
  end
  before_action only: [:index] do
    is_member_in @group
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

    redirect_to groups_path
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
    params.require(:membership).permit(:group_id, :user_id, :admin)
  end
end
