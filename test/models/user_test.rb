require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

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
    assert @user.authenticated?(@user.remember_token)
  end

  test "authenticated? should return true if the remember_token is not correct" do
    @user.save
    @user.remember
    assert_not @user.authenticated?("sbagliato")
  end

  test "authenticated? should return false for a user with nil digest" do
    @user.save
    assert_not @user.authenticated?('')
  end

  test "forget should update remember_digest to nil" do
    @user.save
    @user.remember
    @user.forget
    assert @user.remember_digest.nil?
  end

  test "groups should return user groups" do
    assert users(:user_1).groups
  end

end