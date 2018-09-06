require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  fixtures :groups, :degrees

  def setup
    @degree = degrees(:ingegneria_informatica)
    @degree.degrees_courses.each_with_index do |degree_course, index|
      degree_course.update_attribute(:group_id, Group.all[index].id)
    end
  end

  test "should not save if name is not supplied" do
    assert_not Degree.new(years: 2).save
  end

  test "should not save if years is not supplied" do
    assert_not Degree.new(name: "fake degree").save
  end

  test "should not save if name is not unique" do
    name = "fake_degree"
    Degree.new(name: name, years: 2).save!
    assert_not Degree.new(name: name, years: 3).save
  end

  test "groups should return all degrees_courses groups if no year is passed as argument" do
    group_ids = @degree.groups.ids
    degree_course_group_ids = @degree.degrees_courses.to_a.map {|degree_course| degree_course.group_id}
    assert_equal degree_course_group_ids.sort, group_ids.sort
  end

  test "groups should return degrees_courses groups of the year passed as argument" do
    year = 1
    group_ids = @degree.groups(year).ids
    degree_course_group_ids = @degree.degrees_courses.where(year: year).to_a.map {|degree_course| degree_course.group_id}
    assert_equal degree_course_group_ids.sort, group_ids.sort
  end

  test "courses.year should return courses of a specific year if a year is passed as argument" do
    degree = degrees(:ingegneria_informatica)
    year = 1
    courses = degree.courses.year year
    expected = Course.joins("JOIN degrees_courses ON degrees_courses.course_id = courses.id")
                      .where("degrees_courses.degree_id = ?", degree.id)
                      .where("degrees_courses.year = ?", year).ids.sort
    assert_equal expected, courses.ids.sort
  end

end