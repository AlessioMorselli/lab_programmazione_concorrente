require 'test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :groups

  def setup
    st_time = Time.now + 2.hours
    @event = Event.new(start_time: st_time, end_time: st_time + 2.hours, place: "Aula 20", description: "Generic description", group_id: groups(:group_1).id)
  end

  test "should save if everything is supplied" do
    assert @event.save
  end

  test "should not save if group is not supplied" do
    @event.group_id = nil
    assert_not @event.save
  end

  test "should not save if start_time is not supplied" do
    @event.start_time = nil
    assert_not @event.save
  end

  test "should not save if end_time is not supplied" do
    @event.end_time = nil
    assert_not @event.save
  end

  test "should not save if end_time is less than start_time" do
    @event.end_time = @event.start_time - 1.hour
    assert_not @event.save
  end

  test "should not save if start_time is less than today" do
    @event.start_time = Time.now - 1.hour
    assert_not @event.save
  end

  test "duration should return the difference between end_time and start_time" do
    @event.end_time = @event.start_time + 2.hour + 20.minutes
    assert_equal @event.duration, "02:20:00"
  end

end
