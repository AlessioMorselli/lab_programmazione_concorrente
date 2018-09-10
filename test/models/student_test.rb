require 'test_helper'

class StudentTest < ActiveSupport::TestCase

  def setup
    @degree = Degree.new(name: "degree_123", years: 3)
    @degree.save
    @user = User.new(name: "name", email: "name@student.it", password: "password")
    @user.save
  end

  test "should not save if no year is supplied" do
    assert_not Student.new(user_id: @user.id, degree_id: @degree.id).save
  end

  test "should replace the previous degree if there is one" do
    degree_2 = Degree.new(name: "degree_456", years: 5)
    degree_2.save!
    student_1 = Student.new(user_id: @user.id, degree_id: @degree.id, year: 1)
    student_2 = Student.new(user_id: @user.id, degree_id: degree_2.id, year: 2)
    student_1.save!
    assert_equal @degree, @user.degree
    student_2.save!
    @user.reload
    assert_equal degree_2, @user.degree
  end

  test "should not save if year is greater than degree years" do
    assert_not Student.new(user_id: @user.id, degree_id: @degree.id, year: @degree.years+1).save
  end

  test "after_save should add the user to the courses of the year of the degree" do
    year = 1
    g1 = Group.first
    DegreeCourse.create!(year: year, degree_id: @degree.id, course_id: Course.ids.first, group_id: g1.id)
    g2 = Group.second
    DegreeCourse.create!(year: year, degree_id: @degree.id, course_id: Course.ids.second, group_id: g2.id)

    Student.create(degree_id: @degree.id, user_id: @user.id, year: year)

    @degree.groups(year).each do |g|
      assert g.members.ids.include? @user.id
    end
  end

  test "after_save should remove the user from the official groups of the previouse degree and add him to the group of the current degree" do
    year_one = 1
    DegreeCourse.create!(year: year_one, degree_id: @degree.id, course_id: Course.first!.id, group_id: Group.first!.id)
    DegreeCourse.create!(year: year_one, degree_id: @degree.id, course_id: Course.second!.id, group_id: Group.second!.id)
    Student.create!(degree_id: @degree.id, user_id: @user.id, year: year_one)

    @degree.groups(year_one).each do |group|
      assert group.members.ids.include? @user.id
    end

    year_two = 2

    DegreeCourse.create!(year: year_two, degree_id: @degree.id, course_id: Course.third!.id, group_id: Group.third!.id)
    DegreeCourse.create!(year: year_two, degree_id: @degree.id, course_id: Course.fourth!.id, group_id: Group.fourth!.id)
    Student.create!(degree_id: @degree.id, user_id: @user.id, year: year_two)
    
    @degree.groups(year_one).each do |group|
      assert_not group.members.ids.include? @user.id
    end

    @degree.groups(year_two).each do |group|
      assert group.members.ids.include? @user.id
    end
  end

end