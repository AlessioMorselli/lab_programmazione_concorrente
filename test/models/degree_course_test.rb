require 'test_helper'

class DegreeCourseTest < ActiveSupport::TestCase

  def setup
    @degree = Degree.new(name: "my_degree", years: 3)
    @degree.save!
    @course = Course.new(name: "my_course")
    @course.save!
    @group = Group.new(name: "my_group")
    @group.save!
  end

  test "should save if everything is supplied" do
    assert DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, group_id: @group.id, year: 1).save
  end

  test "should not save if degree_id is not supplied" do
    assert_not DegreeCourse.new(course_id: @course.id, group_id: @group.id, year: 1).save
  end

  test "should not save if course_id is not supplied" do
    assert_not DegreeCourse.new(degree_id: @degree.id, group_id: @group.id, year: 1).save
  end

  test "should not save if year is not supplied" do
    assert_not DegreeCourse.new(course_id: @course.id, group_id: @group.id, degree_id: @degree.id).save
  end

  test "should not save if group_id is not supplied" do
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, year: 1).save
  end

  test "should not save if year is less than 1" do
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, group_id: @group.id, year: 0).save
  end

  test "should not save if year is greater than degree years" do
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, group_id: @group.id, year: @degree.years+1).save
  end

  test "should not save if there is already a DegreeCourse with same degree_id and course_id" do
    DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, group_id: @group.id, year: 2).save!
    assert_not DegreeCourse.new(course_id: @course.id, degree_id: @degree.id, group_id: @group.id, year: 2).save
  end

end