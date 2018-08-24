require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users, :groups

  def setup
    @group = Group.new(name: "fake group")
    @user_1 = users(:giorgio)
    @user_2 = users(:giovanni)
    @user_3 = users(:luigi)
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
    @group.members << @user_1
    @group.members << @user_2
    @group.max_members = 1
    assert_not @group.save
  end

  test "should raise exception when adding more members than max_members" do
    @group.max_members = 1
    @group.save
    @group.members << @user_1

    assert_raises Exception do
      @group.members << @user_2
    end

    assert_equal @group.max_members, @group.members.size
  end

  test "admins method should return the group's admins" do
    @group.save
    membership = Membership.create(group_id: @group.id, user_id: @user_1.id, admin: true)
    assert @group.admins.to_a.include? @user_1
  end

  test "should also delete all memberships when deleting group" do
    @group.save
    group_id = @group.id
    @group.members << @user_1
    @group.members << @user_2
    @group.members << @user_3
    assert Membership.all.where(group_id: group_id).size > 0
    @group.destroy
    assert_equal Membership.all.where(group_id: group_id).size, 0
  end

  test "should also delete all messages when deleting group" do
    @group.save
    group_id = @group.id
    Message.create(group_id: group_id, user_id: @user_1.id, text: "ciao")
    Message.create(group_id: group_id, user_id: @user_2.id, text: "ciao")
    Message.create(group_id: group_id, user_id: @user_3.id, text: "ciao")
    assert Message.all.where(group_id: group_id).size > 0
    @group.destroy
    assert_equal Message.all.where(group_id: group_id).size, 0
  end

  test "should also delete all invitations when deleting group" do
    @group.save
    group_id = @group.id
    Invitation.create(group_id: group_id, user_id: @user_1.id)
    Invitation.create(group_id: group_id, user_id: @user_2.id)
    Invitation.create(group_id: group_id, user_id: @user_3.id)
    assert Invitation.all.where(group_id: group_id).size == 3
    @group.destroy
    assert_equal Invitation.all.where(group_id: group_id).size, 0
  end

  test "save_with_admin should save the group and add the user as a super_admin" do
    @group.save_with_admin(@user_1)
    assert_equal @group.super_admin, @user_1
  end

  test "save_with_admin should not save the group and add the super_admin if the group is not new" do
    @group.save
    @group.save_with_admin(@user_1)
    assert_not_equal @group.super_admin, @user_1
  end

  test "save_with_admin should not save the group and add the super_admin if the group is not valid" do
    @group.name = nil
    @group.save_with_admin(@user_1)
    assert_not_equal @group.super_admin, @user_1
  end

  test "change_super_admin should switch the current super_admin to the the user passed as argument" do
    assert @group.save_with_admin(@user_1)
    assert Membership.new(group_id: @group.id, user_id: @user_2.id).save
    assert @group.change_super_admin(@user_2)
    assert_equal @group.super_admin, @user_2
  end

  test "change_super_admin should not switch the current super_admin if the user passed as argument is not member of the group" do
    assert @group.save_with_admin(@user_1)
    assert_not @group.change_super_admin(@user_2)
    assert_equal @group.super_admin, @user_1
  end

  test "user_query should return groups where the name or the name of course contains the query passed" do
    course_1 = Course.new(name: "no1")
    course_1.save
    course_2 = Course.new(name: "no2")
    course_2.save
    course_3 = Course.new(name: "da trovare1")
    course_3.save
    course_4 = Course.new(name: "da trovare2")
    course_4.save
    course_5 = Course.new(name: "da trovare3")
    course_5.save

    groups = [
      group_1 = Group.new(name: "da trovare", course_id: course_1.id),
      group_2 = Group.new(name: "da trovare", course_id: course_2.id),
      group_3 = Group.new(name: "no", course_id: course_3.id),
      group_4 = Group.new(name: "no", course_id: course_4.id),
      group_5 = Group.new(name: "no", course_id: course_5.id),
    ]

    groups.each { |g| g.save }

    assert_equal groups.map{|g| g.id}.sort, Group.user_query("trovare").ids.sort
  end

  test "with_user should return groups where the user passed as argument is a member" do
    Group.with_user(@user_1).ids.each do |group_id|
      assert @user_1.groups.ids.include?(group_id)
    end
  end

  test "without_user should return groups where the user passed as argument is not a member" do
    Group.without_user(@user_1).ids.each do |group_id|
      assert_not @user_1.groups.ids.include?(group_id)
    end
  end

  test "is_official should return true if the group is linked to a degree_course" do
    @group.save
    DegreeCourse.where("degrees_courses.group_id IS NULL").first.update_attribute(:group_id, @group.id)
    group_id = DegreeCourse.where("degrees_courses.group_id IS NOT NULL").first.group_id
    assert Group.find(group_id).is_official
  end
end
