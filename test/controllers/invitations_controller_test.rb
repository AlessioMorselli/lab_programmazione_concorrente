require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :users, :invitations

  def setup
    @user = users(:user_1)
    log_in_as(@user)
    @group = groups(:group_1)
    @invitation = invitations(:invitation_1)
  end

  test "index" do
    get user_invitations_path(@user)
    assert_response :success
  end

  test "new" do
    get new_group_invitation_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "create" do
    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: 2
        }
      }
    end
   
    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "delete" do
    # TODO: il delete non è ancora definito, da rivedere
    assert_difference('Invitation.count', -1) do
      delete group_invitation_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to group_path(uuid: @group.uuid)
  end
end
