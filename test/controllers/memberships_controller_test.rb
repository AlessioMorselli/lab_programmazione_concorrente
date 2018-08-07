require 'test_helper'

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :users

  test "index" do
    get group_memberships_path(:group_1)
    assert_response :success
  end
end
