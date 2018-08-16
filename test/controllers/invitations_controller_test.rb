require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :users, :invitations

  def setup
    @user = users(:user_1)
    log_in_as(@user)
    @group = groups(:group_75)
    @invitation = invitations(:invitation_1)
    @public_invitation = invitations(:invitation_public_1)
  end

  test "should index every user's invitation" do
    get user_invitations_path(@user)
    assert_response :success
  end

  test "should show choices for an invitation" do
    get group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    assert_response :success
  end

  test "should show a form to create a new invitation" do
    get new_group_invitation_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should create a new private invitation" do
    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: @user.id
        }
      }
    end
   
    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "should create a new public invitation" do
    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: nil
        }
      }
    end
   
    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "should destroy an invitation" do
    assert_difference('Invitation.count', -1) do
      delete group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end
  end

  test "should accept a private invitation" do
    @invitation_group = @invitation.group
    assert_difference('Invitation.count', -1) do
      assert_difference('Membership.count', 1) do
        get group_accept_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @invitation_group.uuid)
  end

  test "should refuse a private invitation" do
    assert_difference('Invitation.count', -1) do
      get group_refuse_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to groups_path
  end

  test "should accept a public invitation" do
    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 1) do
        get group_accept_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @invitation.group.uuid)
  end

  test "should refuse a public invitation" do
    assert_difference('Invitation.count', 0) do
      get group_refuse_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to groups_path
  end
end
