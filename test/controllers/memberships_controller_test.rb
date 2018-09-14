require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @group = groups(:samurai)
    @user = users(:giovanni) # utente membro non admin
    @other_user = users(:luigi) # utente membro non admin diverso da @user

    set_last_message_cookies(@user, @group, DateTime.now)

    @non_member = users(:aldo) # utente non membro
    @admin = users(:giacomo) # utente admin
    @other_admin = users(:giorgio) # anche super admin

    @user_membership = memberships(:membro_samurai_2)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should index every group member" do
    log_in_as @user

    get group_memberships_path(group_uuid: @group.uuid)
    assert_response :success

    assert_equal 4, assigns(:members).length
  end

  test "should remove logged user from group" do
    log_in_as @user

    assert_difference('Membership.count', -1) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to groups_path
    assert_empty cookies[@user.id.to_s + @group.uuid]
  end

  test "should not add user to public group if it is already member" do
    log_in_as @user

    assert_difference("Membership.count", 0) do
      post group_memberships_path(group_uuid: @group.uuid)
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert flash.empty?
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
    log_in_as @other_user

    assert_difference('Membership.count', 0) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON MEMBRO ###
  test "should not index every group member if logged user is not a member" do
    log_in_as @non_member

    get group_memberships_path(group_uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should add user to public group" do
    log_in_as @non_member

    assert_difference("Membership.count", 1) do
      post group_memberships_path(group_uuid: @group.uuid)
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

### TEST PER UN UTENTE AMMINISTRATORE ###
  test "should remove another user from group if logged user is admin" do
    log_in_as @admin

    assert_difference('Membership.count', -1) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not remove another user from group if logged user is admin and that user is admin" do
    log_in_as @admin

    assert_difference('Membership.count', 0) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @other_admin.id)
    end
    
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not give admin title if logged user is admin and not super admin" do
    log_in_as @admin

    patch group_set_admin_path(group_uuid: @group.uuid, user_id: @user.id)
    
    assert_not @group.admins.include? @user
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not remove admin title if logged user is admin and not super admin" do
    # Fornisco a @user il titolo di admin
    @user_membership.update!(admin: true)

    log_in_as @admin

    patch group_set_admin_path(group_uuid: @group.uuid, user_id: @user.id)
    
    assert @group.admins.include? @user
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not transfer super admin title if logged user is not super admin" do
    log_in_as @admin

    patch group_set_super_admin_path(group_uuid: @group.uuid, user_id: @admin.id)
    
    assert_not_equal @admin, @group.super_admin
    assert_equal @other_admin, @group.super_admin
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

### TEST PER UTENTE SUPER AMMINISTRATORE ###
  test "should give admin title if logged user is super admin" do
    log_in_as @other_admin

    patch group_set_admin_path(group_uuid: @group.uuid, user_id: @user.id)
    
    assert @group.admins.include? @user
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should remove admin title if logged user is super admin" do
    log_in_as @other_admin

    patch group_set_admin_path(group_uuid: @group.uuid, user_id: @admin.id)
    
    assert_not @group.admins.include? @admin
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should transfer super admin title" do
    log_in_as @other_admin

    patch group_set_super_admin_path(group_uuid: @group.uuid, user_id: @admin.id)
    
    assert_equal @admin, @group.super_admin
    assert_not_equal @other_admin, @group.super_admin
    assert @group.admins.include? @other_admin
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end
end
