require 'test_helper'

class MembersControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :members, :users

  test "index" do
    get group_members(:group_1)
    assert_response :success
  end
end
