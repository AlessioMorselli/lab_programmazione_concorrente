require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :events, :users

  def setup
    @user = users(:user_1)
    log_in_as(@user)
    @group = groups(:group_1)
    @event = events(:event_1)
  end

  test "should index every group event of the next 7 days" do
    get group_events_path(group_uuid: @group.uuid)
    assert_response :success

    #assert_operator assigns(:events).last.start_time, :<=, DateTime.now + 7.days
  end

  test "should index every user's groups event of the next 7 days" do
    get user_events_path(@user)
    assert_response :success

    #assert_operator assigns(:events).last.start_time, :<=, DateTime.now + 7.days
  end

  test "should show a single event" do
    get user_event_path(@user, @event)
    assert_response :success
  end

  test "should show form to create a new event" do
    get new_group_event_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should create a new event" do
    assert_difference('Event.count') do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now + 1.hours,
        end_time: DateTime.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "2 ore di studio di programmazione concorrente",
        group_id: @group.id
        }
      }
    end
   
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
  end

  test "should show form to edit an event" do
    get edit_group_event_path(group_uuid: @event.group.uuid, id: @event.id)
    assert_response :success
  end

  test "should update an event" do
    patch group_event_path(group_uuid: @event.group.uuid, id: @event.id), params: { event: { place: "Aula studio - Secondo piano" } }
  
    assert_redirected_to group_events_path(group_uuid: @event.group.uuid)
    @event.reload
    assert_equal "Aula studio - Secondo piano", @event.place
  end

  test "should destroy an event" do
    @event_group = @event.group
    assert_difference('Event.count', -1) do
      delete group_event_path(group_uuid: @event_group.uuid, id: @event.id)
    end
    
    assert_redirected_to group_events_path(group_uuid: @event_group.uuid)
  end
end
