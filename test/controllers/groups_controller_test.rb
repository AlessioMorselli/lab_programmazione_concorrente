require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
    log_in_as(@user)

    @group = groups(:group_1)
    set_last_message_cookies(@group, DateTime.now - 1.hour)
  end

  test "should index suggested groups" do
    get groups_path
    assert_response :success
  end

  test "should show a group chat" do
    get group_path(uuid: @group.uuid)
    assert_not_empty cookies[@group.uuid]
    assert_equal DateTime.now.to_s, cookies[@group.uuid]
    assert_response :success
  end

  test "should show a form to create a new group" do
    get new_group_path
    assert_response :success
  end

  test "should create a new group with an admin member" do
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

  test "should show a form to edit a group" do
    get edit_group_path(uuid: @group.uuid)
    assert_response :success
  end

  test "should update a group" do 
    patch group_path(uuid: @group.uuid), params: { group: { name: "Nuovi ciccioni" } }
  
    assert_redirected_to group_path(uuid: @group.uuid)

    @group.reload
    assert_equal "Nuovi ciccioni", @group.name
  end

  test "should destroy a group with its messages, event, members and invitations" do
    assert_difference('Group.count', -1) do
      assert_difference('Message.count', (-1) * @group.messages.count) do
        assert_difference('Event.count', (-1) * @group.events.count) do
          assert_difference('Membership.count', (-1) * @group.memberships.count) do
            assert_difference('Invitation.count', (-1) * @group.invitations.count) do
              delete group_path(uuid: @group.uuid)
            end
          end
        end
      end
    end
    
    assert_redirected_to groups_path
  end
end
