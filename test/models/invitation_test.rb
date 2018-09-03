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

  test "should not save if expiration_date is before now" do
    @invitation.expiration_date = Time.now - 1.hour
    assert_not @invitation.save
  end

  test "should not save if the couple user_id, group_id is not unique (even if user_id is nil)" do
    inv1 = invitations(:invito_ninja_giorgio)
    inv2 = invitations(:invito_ninja_giovanni)
    inv3 = invitations(:invito_pirati_mario_scaduto)
    inv4 = invitations(:invito_pirati)

    inv1.user_id = @user.id
    inv1.group_id = @group.id
    inv1.expiration_date = nil
    assert inv1.save
    inv2.user_id = @user.id
    inv2.group_id = @group.id
    inv2.expiration_date = nil
    assert_not inv2.save

    inv3.user_id = nil
    inv3.group_id = @group.id
    inv3.expiration_date = nil
    assert inv3.save
    inv4.user_id = nil
    inv4.group_id = @group.id
    inv4.expiration_date = nil
    assert_not inv4.save
  end

  test "should add url_string before save" do
    @invitation.save
    assert @invitation.url_string
  end

  test "is_expired should return if the expiration_date was passed" do
    @invitation.expiration_date = 1.week.ago
    @invitation.save
    assert @invitation.is_expired?
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
    user = users(:giorgio)
    assert_not @invitation.accept(user)
  end

  test "not_expired should return invitations where expiration date is not passed or is null" do
    invitations = Invitation.not_expired
    assert invitations.where("expiration_date > ?", Time.now).count > 0
    assert invitations.where("expiration_date IS NULL").count > 0
    assert_equal 0, invitations.where("expiration_date < ?", Time.now).count
  end

  test "save should delete the existing invitation if it's expired and create a new one" do
    assert @invitation.save
    @invitation.update_attribute(:expiration_date, Time.now-1.hour)
    new_invitation = Invitation.new(group_id: @group.id, user_id: @user.id, expiration_date: Time.now+1.hour)
    assert new_invitation.save
    assert_equal 1, Invitation.where(group_id: @group.id).where(user_id: @user.id).count
    assert_equal (Time.now+1.hour).utc.to_a, new_invitation.expiration_date.to_a
  end

  test "save should not create a new invitation if there is already one not expired" do
    assert @invitation.save
    @invitation.update_attribute(:expiration_date, Time.now+1.hour)
    new_invitation = Invitation.new(group_id: @group.id, user_id: @user.id, expiration_date: Time.now+2.hours)
    assert_not new_invitation.save
    assert_equal 1, Invitation.where(group_id: @group.id).where(user_id: @user.id).count
    assert_equal (Time.now+1.hour).utc.to_a, @invitation.expiration_date.to_a
  end
end
