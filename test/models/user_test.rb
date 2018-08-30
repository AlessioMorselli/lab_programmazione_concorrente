require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :degrees

  def setup
    @user = User.new(name: "name", email: "name@student.it", password: "password")
  end

  test "should save user if name, email, password are supplied" do
    assert @user.save
  end

  test "should not save user if name is not supplied" do
    @user.name = nil
    assert_not @user.save
  end

  test "should not save user if email is not supplied" do
    @user.email = nil
    assert_not @user.save
  end

  test "should not save user if password is not supplied" do
    @user.password = nil
    assert_not @user.save
  end

  test "should not save user if name is too short" do
    @user.name = "ab"
    assert_not @user.save
  end
  
  test "should not save user if name is too long" do
    @user.name = "a"*51
    assert_not @user.save
  end

  test "should not save user if email has wrong format" do
    @user.email = "name@studentit"
    assert_not @user.save
  end

  test "should not save user if email is too long" do
    @user.email = "name@"+"a"*250+".it"
    assert_not @user.save
  end

  test "should not save user if password is too short" do
    @user.password = "pass"
    assert_not @user.save
  end

  test "email should be unique" do
    User.new(name: "name", email: "name@student.it", password: "password").save
    assert_not User.new(name: "other_name", email: "name@student.it", password: "password").save
  end

  test "name should be unique" do
    User.new(name: "name", email: "name@student.it", password: "password").save
    assert_not User.new(name: "name", email: "other_name@student.it", password: "password").save
  end

  test "email should be saved downcase" do
    email = "NAme@STUdenT.iT"
    @user.email = email
    @user.save
    assert_equal @user.email, email.downcase
  end

  test "remember should generate new token and insert hash in remember_digest" do
    @user.save
    @user.remember
    assert BCrypt::Password.new(@user.remember_digest).is_password?(@user.remember_token)
  end

  test "authenticated? should return true if the remember_token is correct" do
    @user.save
    @user.remember
    assert @user.authenticated?(:remember, @user.remember_token)
  end

  test "authenticated? should return true if the remember_token is not correct" do
    @user.save
    @user.remember
    assert_not @user.authenticated?(:remember, "sbagliato")
  end

  test "authenticated? should return false for a user with nil digest" do
    @user.save
    assert_not @user.authenticated?(:remember, '')
  end

  test "forget should update remember_digest to nil" do
    assert @user.save
    @user.remember
    @user.forget
    assert @user.remember_digest.nil?
  end

  test "degree should return the user degree" do
    degree = degrees(:ingegneria_informatica)
    assert @user.save
    student = Student.new(user_id: @user.id, degree_id: degree.id, year: 1)
    assert student.save
    assert_equal degree, @user.degree
  end

  test "courses should return the user courses" do
    degree = degrees(:ingegneria_informatica)
    assert @user.save
    student = Student.new(user_id: @user.id, degree_id: degree.id, year: 1)
    assert student.save
    assert_equal degree.courses, @user.courses
  end

  test "suggested_groups should return groups where the course is in the user degree courses and that are not private and without user" do
    user = users(:giorgio)
    courses = user.degree.courses.ids
    suggested = user.suggested_groups.to_a
    suggested.each do |group|
      assert_not user.groups.ids.include?(group.id)
      assert_not group.private
      assert_includes courses, group.course_id
    end
  end

  test "events should return all the events of all the user's groups" do
    user = users(:giorgio)
    expected_events = Event.joins("JOIN memberships ON events.group_id = memberships.group_id").where("memberships.user_id = ?", user.id)
    assert_equal expected_events.ids.sort, user.events.ids.sort
  end

  test "should set email_confirm_token before create" do
    user = User.new(name: "name", email: "name@student.it", password: "password")
    assert user.confirm_token.nil?
    assert user.save
    assert_not user.confirm_token.nil?
  end

  test "email_activate should set email_confirmed to true" do
    user = User.new(name: "name", email: "name@student.it", password: "password")
    assert user.save
    assert_not user.confirmed?
    user.activate
    assert user.confirmed
  end

end