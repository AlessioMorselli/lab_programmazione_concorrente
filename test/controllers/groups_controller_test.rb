require 'test_helper'
include ActionDispatch::Routing::UrlFor
include Rails.application.routes.url_helpers

class GroupsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :users, :messages, :events, :attachments

  def setup
    @user = users(:user_1)
    log_in_as(@user)
    @group = groups(:group_1)
  end

  test "index" do
    get groups_path
    assert_response :success
  end

  test "show" do
    get group_path(uuid: @group.uuid)
    assert_response :success
  end

  test "new" do
    get new_group_path
    assert_response :success
  end

  test "create" do
    assert_difference('Group.count') do
      assert_difference('Membership.count') do
        post groups_path, params: { group: {
          name: "I ciccioni",
          max_members: 10,
          private: true,
          course_id: nil
          }
        }
      end
    end

    assert_redirected_to group_path(uuid: Group.find_by_name("I ciccioni").uuid)
  end

  test "edit" do
    get edit_group_path(uuid: @group.uuid)
    assert_response :success
  end

  test "update" do 
    patch group_path(uuid: @group.uuid), params: { group: { name: "Nuovi ciccioni" } }
  
    assert_redirected_to group_path(uuid: @group.uuid)
    # Reload association to fetch updated data and assert that value is updated.
    @group.reload
    assert_equal "Nuovi ciccioni", @group.name
  end

  test "delete" do
    # TODO: devo verificare che vengano cancellati anche messaggi, eventi, membri e inviti
    assert_difference('Group.count', -1) do
      delete group_path(uuid: @group.uuid)
    end
    
    assert_redirected_to groups_path
  end
end
