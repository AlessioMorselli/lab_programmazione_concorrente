require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @membership = Membership.all.first
    @group = @membership.group
    @user = @membership.user
    log_in_as(@user)
    set_last_message_cookies(@user, @group, DateTime.now)
  end

  test "should index every group member" do
    get group_memberships_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should remove logged user from group" do
    assert_difference('Membership.count', -1) do
      delete group_membership_path(group_uuid: @group.uuid, user_id: @user.id)
    end
    
    assert_redirected_to groups_path
    assert_empty cookies[@user.id.to_s + @group.uuid]
  end
end
