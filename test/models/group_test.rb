require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @group = Group.new(name: "fake group")
  end

  test "should save group if name is supplied" do
    assert @group.save
  end

  test "should not save group if name is not supplied" do
    @group.name = nil
    assert_not @group.save
  end

  test "should save group if max_members is a positive integer" do
    @group.max_members = 1
    assert @group.save
  end

  test "should save group if max_members is -1" do
    @group.max_members = -1
    assert @group.save
  end

  test "should not save group if max_members less than -1" do
    @group.max_members = -2
    assert_not @group.save
  end

  test "should not save group if max_members is 0" do
    @group.max_members = 0
    assert_not @group.save
  end

  test "should not save group if max_members is not an integer" do
    @group.max_members = 2.1
    assert_not @group.save
  end

  test "should not save group if max_members is less than the current number of members" do
    @group.save
    @group.members << users(:user_1)
    @group.members << users(:user_2)
    @group.max_members = 1
    assert_not @group.save
  end

  test "should raise exception when adding more members than max_members" do
    @group.max_members = 1
    @group.save
    @group.members << users(:user_1)

    assert_raises Exception do
      @group.members << users(:user_2)
    end

    assert_equal @group.max_members, @group.members.size
  end

  test "admin method should return the group's admin" do
    @group.save
    membership = Membership.create(group_id: @group.id, user_id: users(:user_1).id, admin: true)
    assert_equal @group.admin, users(:user_1)
  end

  test "should also delete all memberships when deleting group" do
    @group.save
    group_id = @group.id
    @group.members << users(:user_1)
    @group.members << users(:user_2)
    @group.members << users(:user_3)
    assert Membership.all.where(group_id: group_id).size > 0
    @group.destroy
    assert_equal Membership.all.where(group_id: group_id).size, 0
  end

  test "should also delete all messages when deleting group" do
    @group.save
    group_id = @group.id
    Message.create(group_id: group_id, user_id: users(:user_1).id, text: "ciao")
    Message.create(group_id: group_id, user_id: users(:user_2).id, text: "ciao")
    Message.create(group_id: group_id, user_id: users(:user_3).id, text: "ciao")
    assert Message.all.where(group_id: group_id).size > 0
    @group.destroy
    assert_equal Message.all.where(group_id: group_id).size, 0
  end

  test "should also delete all invitations when deleting group" do
    @group.save
    group_id = @group.id
    Invitation.create(group_id: group_id, user_id: users(:user_1).id)
    Invitation.create(group_id: group_id, user_id: users(:user_2).id)
    Invitation.create(group_id: group_id, user_id: users(:user_3).id)
    assert Invitation.all.where(group_id: group_id).size == 3
    @group.destroy
    assert_equal Invitation.all.where(group_id: group_id).size, 0
  end

end
