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

  test "get_one should return the membership with group and user passed as arguments" do
    @group.members << users(:user_1)
    assert_equal @group.memberships.where(user_id: users(:user_1).id).first.attributes, Membership.get_one(users(:user_1), @group).attributes
  end

end