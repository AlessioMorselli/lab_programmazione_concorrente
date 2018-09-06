require 'test_helper'

class EventTest < ActiveSupport::TestCase
  fixtures :groups

  def setup
    now = Time.now

    st_time = now + 2.hours
    @group = groups(:pirati)
    @event = Event.new(name: "evento", start_time: st_time, end_time: st_time + 2.hours, place: "Aula 20", description: "Generic description", group_id: @group.id)

    @events_this_hour = [
      Event.new(name: "evento", start_time: now+1.minute, end_time: now+2.hours),
      Event.new(name: "evento", start_time: now+20.minutes, end_time: now+2.hours),
      Event.new(name: "evento", start_time: now+40.minutes, end_time: now+2.hours),
      Event.new(name: "evento", start_time: now+45.minutes, end_time: now+2.hours),
    ]

    @events_this_week = [
      Event.new(name: "evento", start_time: now+1.day, end_time: now+1.day+2.hours),
      Event.new(name: "evento", start_time: now+2.day, end_time: now+2.day+2.hours),
      Event.new(name: "evento", start_time: now+3.day, end_time: now+3.day+2.hours),
      Event.new(name: "evento", start_time: now+4.day, end_time: now+4.day+2.hours),
      Event.new(name: "evento", start_time: now+5.day, end_time: now+5.day+2.hours),
      Event.new(name: "evento", start_time: now+6.day, end_time: now+6.day+2.hours),
    ]

    @events_next_week = [
      Event.new(name: "evento", start_time: now+8.day, end_time: now+8.day+2.hours),
      Event.new(name: "evento", start_time: now+9.day, end_time: now+9.day+2.hours),
      Event.new(name: "evento", start_time: now+10.day, end_time: now+10.day+2.hours),
    ]

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

  test "should not save if start_time is less than now" do
    @event.start_time = Time.now - 1.hour
    assert_not @event.save
  end

  test "should not save if name is not supplied" do
    @event.name = nil
    assert_not @event.save
  end

  test "should not save if end time is in a different day than start time" do
    @event.end_time = (@event.start_time + 1.day).beginning_of_day + 1.hour
    assert_not @event.save
  end

  test "duration should return the difference between end_time and start_time" do
    @event.end_time = @event.start_time + 2.hour + 20.minutes
    assert_equal @event.duration, "02:20:00"
  end

  test "next should return events in the next week if no argument is passed" do
    group = Group.new(name: "fake group")
    group.save!
    group.events << @events_this_week
    group.events << @events_next_week

    assert_equal @events_this_week.size, group.events.next.count
  end

  test "next should return events in the next hour, including events not finished, if 1.hour is passed as argument" do
    group = Group.new(name: "fake group")
    group.save!
    group.events << @events_this_hour
    group.events << @events_this_week

    assert_equal @events_this_hour.size, group.events.next(1.hour).count
  end

  test "after create should create repeated events if repeated and repeated_for are supplied" do
    event = Event.new(repeated: 7.day, repeated_for: 10, name: "evento con nome unico", start_time: Time.now+1.hour, end_time: Time.now + 2.hours, place: "Aula 20", description: "Generic description", group_id: @group.id)
    event.save!
    assert_equal event.repeated_for, Event.where("name = ?", event.name).count
  end

  test "after create should not create repeated events if repeated is not supplied" do
    @event.name = "evento con un nome unico"
    @event.save!
    assert 1, Event.where("name = ?", @event.name).count
  end

end
