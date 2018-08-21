require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
    @group = groups(:group_75)
    @group1 = groups(:group_1)
    @invitation = Invitation.where(user_id: @user.id, group_id: @group.id).first
    @public_invitation = Invitation.where(user_id: nil, group_id: @group1.id).first

    @other_user = users(:user_2)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should index every user's invitation" do
    log_in_as(@user)

    get user_invitations_path(@user)
    assert_response :success
  end

  test "should show choices for an invitation" do
    log_in_as(@user)

    get group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    assert_response :success
  end

  test "should show a form to create a new invitation" do
    log_in_as(@user)

    get new_group_invitation_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should create a new private invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group1.uuid), params: { invitation: {
        group_id: @group1.id,
        user_id: @user.id
        }
      }
    end
   
    assert_redirected_to group_path(uuid: @group1.uuid)
  end

  test "should not create a new private invitation if an identical invitation exists" do
    log_in_as(@user)

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: @user.id
        }
      }
    end
   
    assert_not flash.empty?
  end

  test "should create a new public invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: nil
        }
      }
    end
   
    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "should not create a new public invitation if an identical invitation exists" do
    log_in_as(@user)

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group1.uuid), params: { invitation: {
        group_id: @group1.id,
        user_id: nil
        }
      }
    end
   
    assert_not flash.empty?
  end

  test "should destroy an invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count', -1) do
      delete group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end
  end

  test "should accept a private invitation" do
    log_in_as(@user)

    @invitation_group = @invitation.group
    assert_difference('Invitation.count', -1) do
      assert_difference('Membership.count', 1) do
        get group_accept_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @invitation_group.uuid)
  end

  test "should refuse a private invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count', -1) do
      get group_refuse_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to groups_path
  end

  test "should accept a public invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 1) do
        get group_accept_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @public_invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @public_invitation.group.uuid)
  end

  test "should refuse a public invitation" do
    log_in_as(@user)

    assert_difference('Invitation.count', 0) do
      get group_refuse_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @public_invitation.url_string)
    end

    assert_redirected_to groups_path
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index every user's invitation if not logged in" do
    get user_invitations_path(@user)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show choices for an invitation if not logged in" do
    get group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a form to create a new invitation if not logged in" do
    get new_group_invitation_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new private invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group1.uuid), params: { invitation: {
        group_id: @group1.id,
        user_id: @user.id
        }
      }
    end
   
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new public invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        group_id: @group.id,
        user_id: nil
        }
      }
    end
   
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not destroy an invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      delete group_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not accept a private invitation if not logged in" do
    @invitation_group = @invitation.group
    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        get group_accept_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not refuse a private invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      get group_refuse_invitation_path(group_uuid: @invitation.group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not accept a public invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        get group_accept_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @public_invitation.url_string)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not refuse a public invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      get group_refuse_invitation_path(group_uuid: @public_invitation.group.uuid, url_string: @public_invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not index every user's invitation if logged user is not correct" do
    log_in_as(@other_user)

    get user_invitations_path(@user)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end
end
