require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :events, :users

  def setup
    @user = users(:user_1)
    log_in_as(@user)
    @group = groups(:group_1)
    @event = events(:event_1)
  end

  test "index" do
    get group_events_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "user_index" do
    get user_events_path(@user)
    assert_response :success
  end

  test "show" do
    get user_event_path(@user, @event)
    assert_response :success
  end

  test "new" do
    get new_group_event_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "create" do
    assert_difference('Event.count') do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now,
        end_time: DateTime.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "3 ore di studio di programmazione concorrente",
        group_id: 1
        }
      }
    end
   
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
  end

  test "should not create with wrong parameters" do
    assert_difference('Event.count', 0) do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now,
        end_time: DateTime.now - 3.hours,
        place: "Aula studio - Secondo piano",
        description: "3 ore di studio di programmazione concorrente",
        group_id: 1
        }
      }
    end

    assert_template 'new'
  end

  test "edit" do
    get edit_group_event_path(group_uuid: @group.uuid, @event)
    assert_response :success
  end

  test "update" do
    patch group_event_path(group_uuid: @group.uuid, @event), params: { event: { place: "Aula studio - Secondo piano" } }
  
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
    event.reload
    assert_equal "Aula studio - Secondo piano", @event.place
  end

  test "delete" do
    assert_difference('Event.count', -1) do
      delete group_event_path(group_uuid: @group.uuid, @event)
    end
    
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
  end
end
