require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  test "should save group if name is supplied" do
    group = Group.new
    group.name = "fake group"
    assert group.save
  end

  test "should not save group if name is not supplied" do
    group = Group.new
    assert_not group.save
  end

  test "should save group if max_members is a positive integer" do
    group = Group.new
    group.name = "fake group"
    group.max_members = 1
    assert group.save
  end

  test "should save group if max_members is -1" do
    group = Group.new
    group.name = "fake group"
    group.max_members = -1
    assert group.save
  end

  test "should not save group if max_members less than -1" do
    group = Group.new
    group.name = "fake group"
    group.max_members = -2
    assert_not group.save
  end

  test "should not save group if max_members is 0" do
    group = Group.new
    group.name = "fake group"
    group.max_members = 0
    assert_not group.save
  end

  test "should not save group if max_members is not an integer" do
    group = Group.new
    group.name = "fake group"
    group.max_members = 2.1
    assert_not group.save
  end

  test "should not save group if max_members is less than the current number of members" do
    # TODO: implement
    assert true
  end

end
