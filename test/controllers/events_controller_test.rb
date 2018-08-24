require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = events(:evento_pirati_1)
    @group = @event.group
    @user = @group.admins.first # membro admin
    @other_user = (@group.members - @group.admins).first # membro non admin
    @non_member = (User.all - @group.members).first
  end

### TEST PER UN UTENTE LOGGATO E AMMINISTRATORE ###
  test "should index every group event of the next 7 days" do
    log_in_as(@user)

    get group_events_path(group_uuid: @group.uuid)
    assert_response :success

    #assert_operator assigns(:events).last.start_time, :<=, DateTime.now + 7.days
  end

  test "should index every user's groups event of the next 7 days" do
    log_in_as(@user)

    get user_events_path(@user)
    assert_response :success

    #assert_operator assigns(:events).last.start_time, :<=, DateTime.now + 7.days
  end

  test "should show a single event" do
    log_in_as(@user)

    get user_event_path(@user, @event)
    assert_response :success
  end

  test "should show form to create a new event" do
    log_in_as(@user)

    get new_group_event_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should create a new event" do
    log_in_as(@user)

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

  test "should not create a new event with start time before now" do
    log_in_as(@user)

    assert_difference('Event.count', 0) do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now - 1.hours,
        end_time: DateTime.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "4 ore di studio di programmazione concorrente",
        group_id: @group.id
        }
      }
    end
   
    assert_not flash.empty?
  end

  test "should not create a new event with end time before start time" do
    log_in_as(@user)

    assert_difference('Event.count', 0) do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now + 3.hours,
        end_time: DateTime.now + 1.hours,
        place: "Aula studio - Secondo piano",
        description: "-2 ore di studio di programmazione concorrente",
        group_id: @group.id
        }
      }
    end
   
    assert_not flash.empty?
  end

  test "should show form to edit an event" do
    log_in_as(@user)

    get edit_group_event_path(group_uuid: @group.uuid, id: @event.id)
    assert_response :success
  end

  test "should update an event" do
    log_in_as(@user)

    patch group_event_path(group_uuid: @group.uuid, id: @event.id), params: {
      event: { place: "Aula studio - Secondo piano" }
    }
  
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
    @event.reload
    assert_equal "Aula studio - Secondo piano", @event.place
  end

  test "should not update an event with start time before now" do
    log_in_as(@user)

    start_time = @event.start_time
    patch group_event_path(group_uuid: @group.uuid, id: @event.id), params: {
      event: { start_time: DateTime.now - 1.hours }
    }

    # Se viene modificato, sono sicuro di scoprirlo
    @event.reload
   
    assert_equal start_time, @event.start_time
    assert_not flash.empty?
  end

  test "should not update an event with end time before start time" do
    log_in_as(@user)

    end_time = @event.end_time
    patch group_event_path(group_uuid: @group.uuid, id: @event.id), params: {
      event: { end_time: DateTime.now - 1.hours }
    }

    # Se viene modificato, sono sicuro di scoprirlo
    @event.reload
   
    assert_equal end_time, @event.end_time
    assert_not flash.empty?
  end

  test "should destroy an event" do
    log_in_as(@user)

    assert_difference('Event.count', -1) do
      delete group_event_path(group_uuid: @group.uuid, id: @event.id)
    end
    
    assert_redirected_to group_events_path(group_uuid: @group.uuid)
  end

### TEST PER UTENTE NON LOGGATO ###
  test "should not index every group event if not logged in" do
    get group_events_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not index every user's groups event if not logged in" do
    get user_events_path(@user)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a single event if not logged in" do
    get user_event_path(@user, @event)

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show form to create a new event if not logged in" do
    get new_group_event_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new event if not logged in" do
    assert_difference('Event.count', 0) do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now + 1.hours,
        end_time: DateTime.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "2 ore di studio di programmazione concorrente",
        group_id: @group.id
        }
      }
    end
   
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show form to edit an event if not logged in" do
    get edit_group_event_path(group_uuid: @group.uuid, id: @event.id)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not update an event if not logged in" do
    place = @event.place
    patch group_event_path(group_uuid: @group.uuid, id: @event.id), params: {
      event: { place: "Aula studio - Secondo piano" }
    }
  
    assert_redirected_to login_path
    assert_not flash.empty?

    @event.reload
    assert_equal place, @event.place
  end

  test "should not destroy an event if not logged in" do
    assert_difference('Event.count', 0) do
      delete group_event_path(group_uuid: @group.uuid, id: @event.id)
    end
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not index every user's groups event if logged user not the correct user" do
    log_in_as(@other_user)

    get user_events_path(@user)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not show a single event if logged user is not correct" do
    log_in_as(@other_user)

    get user_event_path(@user, @event)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON MEMBRO ###
  test "should not index every group event if logged user is not member" do
    log_in_as(@non_member)

    get group_events_path(group_uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON AMMINISTRATORE ###
  test "should not show form to create a new event if logged user is not admin" do
    log_in_as(@other_user)

    get new_group_event_path(group_uuid: @group.uuid)
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not create a new event if logged user is not admin" do
    log_in_as(@other_user)

    assert_difference('Event.count', 0) do
      post group_events_path(group_uuid: @group.uuid), params: { event: {
        start_time: DateTime.now + 1.hours,
        end_time: DateTime.now + 3.hours,
        place: "Aula studio - Secondo piano",
        description: "2 ore di studio di programmazione concorrente",
        group_id: @group.id
        }
      }
    end
  
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not show form to edit an event if logged user is not admin" do
    log_in_as(@other_user)

    get edit_group_event_path(group_uuid: @group.uuid, id: @event.id)
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not update an event if logged user is not admin" do
    log_in_as(@other_user)

    place = @event.place
    patch group_event_path(group_uuid: @group.uuid, id: @event.id), params: {
      event: { place: "Aula studio - Secondo piano" }
    }

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?

    @event.reload
    assert_equal place, @event.place
  end

  test "should not destroy an event if logged user is not admin" do
    log_in_as(@other_user)

    assert_difference('Event.count', 0) do
      delete group_event_path(group_uuid: @group.uuid, id: @event.id)
    end
    
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end
end
