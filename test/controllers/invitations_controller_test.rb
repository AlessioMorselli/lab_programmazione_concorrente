require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :users, :invitations

  def setup
    @user = users(:user_1)
    log_in_as(@user)
  end

  test "index" do
    get user_invitations_path(:user_1)
    assert_response :success
  end

  test "new" do
    get new_group_invitation_path(:group_1)
    assert_response :success
  end

  test "create" do
    assert_difference('Invitation.count') do
      post group_invitations_path(:group_1), params: { invitation: {
        group_id: 1,
        user_id: 1
        }
      }
    end
   
    assert_redirected_to group_path(:group_1)
  end

  test "delete" do
    # TODO: non sapendo come fare il routing, questo test è da rivedere
    invitation = invitations(:invitation_1)
    assert_difference('Invitation.count', -1) do
      delete group_invitation_path(:group_1, invitation)
    end
    
    assert_redirected_to group_path(:group_1)
  end
end
