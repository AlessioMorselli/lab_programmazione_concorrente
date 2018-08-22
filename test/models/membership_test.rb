require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @group = Group.new(name: "fake group")
    @group.save
  end

  test "should not save if the user is already in the group" do
    assert @group.members << users(:user_1)
    assert_not Membership.new(user_id: users(:user_1).id, group_id: @group.id).save
  end

  test "should not save if the number of members in a group is more than its max_members" do
    @group.update_attribute(:max_members, 1)
    assert Membership.new(user_id: users(:user_1).id, group_id: @group.id).save
    assert_not Membership.new(user_id: users(:user_2).id, group_id: @group.id).save
  end

  test "save should set admin to true if super_admin is true" do
    membership = Membership.new(user_id: users(:user_1).id, group_id: @group.id, super_admin: true)
    assert membership.save
    assert membership.admin?
  end

  test "should not save if super_admin is true and there is already a super_admin in the group" do
    assert Membership.new(user_id: users(:user_1).id, group_id: @group.id, super_admin: true).save
    assert_not Membership.new(user_id: users(:user_2).id, group_id: @group.id, super_admin: true).save
  end

  test "get_one should return the membership with group and user passed as arguments" do
    @group.members << users(:user_1)
    assert_equal @group.memberships.where(user_id: users(:user_1).id).first.attributes, Membership.get_one(users(:user_1), @group).attributes
  end


end