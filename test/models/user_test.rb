require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should save user if name, email, password are supplied" do
    assert User.new(name: "name", email: "name@student.it", password: "password").save
  end

  test "should not save user if name is not supplied" do
    assert_not User.new(email: "name@student.it", password: "password").save
  end

  test "should not save user if email is not supplied" do
    assert_not User.new(name: "name", password: "password").save
  end

  test "should not save user if password is not supplied" do
    assert_not User.new(name: "name", email: "name@student.it").save
  end

  test "should not save user if name is too short" do
    assert_not User.new(name: "ab", email: "name@student.it", password: "password").save
  end
  
  test "should not save user if name is too long" do
    assert_not User.new(name: "a"*51, email: "name@student.it", password: "password").save
  end

  test "should not save user if email has wrong format" do
    assert_not User.new(name: "name", email: "name@studentit", password: "password").save
  end

  test "should not save user if email is too long" do
    assert_not User.new(name: "name", email: "name@"+"a"*250+".it", password: "password").save
  end

  test "should not save user if password is too short" do
    assert_not User.new(name: "name", email: "name@student.it", password: "pass").save
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
    user = User.new(name: "name", email: email, password: "password")
    user.save
    assert_equal email.downcase, user.email
  end
end