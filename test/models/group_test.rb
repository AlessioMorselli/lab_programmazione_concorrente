require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users

  test "should save group if name is supplied" do
    assert Group.new(name: "fake group").save
  end

  test "should not save group if name is not supplied" do
    assert_not Group.new.save
  end

  test "should save group if max_members is a positive integer" do
    assert Group.new(name: "fake group", max_members: 1).save
  end

  test "should save group if max_members is -1" do
    assert Group.new(name: "fake group", max_members: -1).save
  end

  test "should not save group if max_members less than -1" do
    assert_not Group.new(name: "fake group", max_members: -2).save
  end

  test "should not save group if max_members is 0" do
    assert_not Group.new(name: "fake group", max_members: 0).save
  end

  test "should not save group if max_members is not an integer" do
    assert_not Group.new(name: "fake group", max_members: 2.1).save
  end

  test "should not save group if max_members is less than the current number of members" do
    group = Group.create(name: "fake group", max_members: 2)
    group.members << users(:user_1)
    group.members << users(:user_2)
    group.max_members = 1
    assert_not group.save
  end

  test "should raise exception when adding more members than max_members" do
    group = Group.create(name: "fake group", max_members: 1)
    group.members << users(:user_1)

    assert_raises Exception do
      group.members << users(:user_2)
    end

    assert_equal group.max_members, group.members.size
  end

end
