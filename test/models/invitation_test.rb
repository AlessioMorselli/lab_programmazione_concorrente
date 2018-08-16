require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  fixtures :invitations, :users

  def setup
    @user = User.create(name: "name", email: "name@student.it", password: "password")
    @group = Group.create(name: "fake group")
    @invitation = Invitation.new(user_id: @user.id, group_id: @group.id)
  end

  test "user_id should be optional" do
    @invitation.user_id = nil
    assert @invitation.save
  end

  test "should not save if the couple user_id, group_id is not unique (even if user_id is nil)" do
    inv1 = invitations(:invitation_1)
    inv2 = invitations(:invitation_2)
    inv3 = invitations(:invitation_3)
    inv4 = invitations(:invitation_4)

    inv1.user_id = @user.id
    inv1.group_id = @group.id
    assert inv1.save
    inv2.user_id = @user.id
    inv2.group_id = @group.id
    assert_not inv2.save

    inv3.user_id = nil
    inv3.group_id = @group.id
    assert inv3.save
    inv4.user_id = nil
    inv4.group_id = @group.id
    assert_not inv4.save
  end

  test "should add url_string before save" do
    @invitation.save
    assert @invitation.url_string
  end

  test "expired should return if the expiration_date was passed" do
    @invitation.expiration_date = 1.week.ago
    @invitation.save
    assert @invitation.expired?
  end

  test "accept should add the user to the group and not destroy the invitation if the invitation is for everyone and it's not expired" do
    @invitation.user = nil
    assert @invitation.save
    @invitation.accept @user
    assert @group.members.include?(@user)
    assert Invitation.exists?(@invitation.id)
  end

  test "accept should add the user to the group and destroy the invitation if the invitation is private and it's not expired" do
    assert @invitation.save
    @invitation.accept
    assert @group.members.include?(@user)
    assert_not Invitation.exists?(@invitation.id)
  end

  test "accept should return false if the invitation is expired" do
    @invitation.expiration_date = Time.now - 1.hour
    @invitation.save
    assert_not @invitation.accept(@user)
  end

  test "accept should return false if the invitation is for everyone and no user is passed" do
    @invitation.user = nil
    @invitation.save
    assert_not @invitation.accept
  end

  test "accept should return false if the invitation is for a user and a different user is passed" do
    @invitation.save
    assert_not @invitation.accept(users(:user_2))
  end

end
