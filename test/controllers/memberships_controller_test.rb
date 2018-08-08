require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :users

  test "index" do
    get group_memberships_path(:group_1)
    assert_response :success
  end

  test "delete" do
    membership = memberships(:membership_1)
    assert_difference('Mambership.count', -1) do
      delete group_memberships(membership.group, membership)
    end
    
    assert_redirected_to groups_path
  end
end
