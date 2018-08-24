require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @group = Group.new(name: "fake group")
    @group.save
  end

  test "should not save if the user is already in the group" do
    user = users(:giorgio)
    assert @group.members << user
    assert_not Membership.new(user_id: user.id, group_id: @group.id).save
  end

  test "should not save if the number of members in a group is more than its max_members" do
    user_1 = users(:giorgio)
    user_2 = users(:giovanni)
    @group.update_attribute(:max_members, 1)
    assert Membership.new(user_id: user_1.id, group_id: @group.id).save
    assert_not Membership.new(user_id: user_2.id, group_id: @group.id).save
  end

  test "save should set admin to true if super_admin is true" do
    user = users(:giorgio)
    membership = Membership.new(user_id: user.id, group_id: @group.id, super_admin: true)
    assert membership.save
    assert membership.admin?
  end

  test "should not save if super_admin is true and there is already a super_admin in the group" do
    user_1 = users(:giorgio)
    user_2 = users(:giovanni)
    assert Membership.new(user_id: user_1.id, group_id: @group.id, super_admin: true).save
    assert_not Membership.new(user_id: user_2.id, group_id: @group.id, super_admin: true).save
  end

  test "get_one should return the membership with group and user passed as arguments" do
    user = users(:giorgio)
    @group.members << user
    assert_equal @group.memberships.where(user_id: user.id).first.attributes, Membership.get_one(user, @group).attributes
  end


end