require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  fixtures :users, :degrees

  def setup
    @degree = Degree.new(name: "degree_123", years: 3)
    @degree.save
    @user = User.new(name: "name", email: "name@student.it", password: "password")
    @user.save
  end

  test "should not save if no year is supplied" do
    assert_not Student.new(user_id: @user.id, degree_id: @degree.id).save
  end

  test "should not save if the user has already a degree" do
    degree_2 = Degree.new(name: "degree_456", years: 5)
    degree_2.save
    student_1 = Student.new(user_id: @user.id, degree_id: @degree.id, year: 1)
    student_2 = Student.new(user_id: @user.id, degree_id: degree_2.id, year: 2)
    assert student_1.save
    assert_not student_2.save
  end

  test "should not save if year is greater than degree years" do
    assert_not Student.new(user_id: @user.id, degree_id: @degree.id, year: @degree.years+1).save
  end

end