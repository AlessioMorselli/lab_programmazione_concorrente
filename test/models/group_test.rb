require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users

  test "should save group if name and admin is supplied" do
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

  test "admin method should return the group's admin" do
    group = Group.create(name: "fake group", max_members: 1)
    membership = Membership.create(group_id: group.id, user_id: users(:user_1).id, admin: true)
    assert_equal group.admin, users(:user_1)
  end

  test "should also delete all memberships when deleting group" do
    group = Group.new(name: "fake group", max_members: 5)
    group.save
    group_id = group.id
    group.members << users(:user_1)
    group.members << users(:user_2)
    group.members << users(:user_3)
    assert Membership.all.where(group_id: group_id).size > 0
    group.destroy
    assert_equal Membership.all.where(group_id: group_id).size, 0
  end

  test "should also delete all messages when deleting group" do
    group = Group.new(name: "fake group", max_members: 5)
    group.save
    group_id = group.id
    Message.create(group_id: group_id, user_id: users(:user_1).id, text: "ciao")
    Message.create(group_id: group_id, user_id: users(:user_2).id, text: "ciao")
    Message.create(group_id: group_id, user_id: users(:user_3).id, text: "ciao")
    assert Message.all.where(group_id: group_id).size > 0
    group.destroy
    assert_equal Message.all.where(group_id: group_id).size, 0
  end

  test "should also delete all invitations when deleting group" do
    group = Group.new(name: "fake group", max_members: 5)
    group.save
    group_id = group.id
    Invitation.create(group_id: group_id, user_id: users(:user_1).id)
    Invitation.create(group_id: group_id, user_id: users(:user_2).id)
    Invitation.create(group_id: group_id, user_id: users(:user_3).id)
    assert Invitation.all.where(group_id: group_id).size > 0
    group.destroy
    assert_equal Invitation.all.where(group_id: group_id).size, 0
  end

end
