require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :users

  def setup
    @membership = memberships(:membership)
  end

  test "index" do
    get group_memberships_path(group_uuid: @membership.group.uuid)
    assert_response :success
  end

  test "delete" do
    # TODO: non sapendo come fare il routing, questo test è da rivedere
    assert_difference('Mambership.count', -1) do
      delete group_memberships(group_uuid: @membership.group.uuid, user_id: @membership.user.id)
    end
    
    assert_redirected_to groups_path
  end
end
