require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :events, :users

  test "index" do
    get group_events_path(:group_1)
    get user_events_path(:user_1)
    assert_response :success
  end

  test "show" do
    get user_event_path(:user_1, :event_1)
    assert_response :success
  end

  test "new" do
    get new_group_event_path(:group_1)
    assert_response :success
  end

  test "create" do
    assert_difference('Event.count') do
      post group_events_path(:group_1), params: { event: {
        date: Date.tomorrow,
        start_time: Time.now,
        end_time: Time.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "3 ore di studio di programmazione concorrente",
        groupo_id: 1
        }
      }
    end
   
    assert_redirected_to group_events_path(:group_1)
  end

  test "edit" do
    get edit_group_event_path(:group_1)
    assert_response :success
  end

  test "update" do
    event = events(1)
 
    patch group_event_path(:group_1, event), params: { event: { place: "Aula studio - Secondo piano" } }
  
    assert_redirected_to group_events_path(:group_1)
    event.reload
    assert_equal "Aula studio - Secondo piano", event.place
  end

  test "delete" do
    event = events(1)
    assert_difference('Event.count', -1) do
      delete group_event_path(:group_1, event)
    end
    
    assert_redirected_to group_events_path(:group_1)
  end
end
