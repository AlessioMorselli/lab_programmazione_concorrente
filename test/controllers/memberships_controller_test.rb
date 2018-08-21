require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @membership = Membership.all.first
    @group = @membership.group
    @user = @membership.user
    @other_user = (@group.members.first == @user ? @group.members.second : @group.members.first)

    set_last_message_cookies(@user, @group, DateTime.now)

    @non_member = (User.all - @group.members).first
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should index every group member" do
    log_in_as(@user)

    get group_memberships_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should remove logged user from group" do
    log_in_as(@user)

    assert_difference('Membership.count', -1) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to groups_path
    assert_empty cookies[@user.id.to_s + @group.uuid]
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index every group member if not logged in" do
    get group_memberships_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not remove a user from group if not logged in" do
    assert_difference('Membership.count', 0) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not remove a user from group if logged user is not correct and it's not admin" do
    log_in_as(@other_user)

    assert_difference('Membership.count', 0) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON MEMBRO ###
  test "should not index every group member if logged user is not a member" do
    log_in_as(@non_member)

    get group_memberships_path(group_uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end
end
