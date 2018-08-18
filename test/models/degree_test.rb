require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  fixtures :users, :degrees

  def setup
    #
  end

  test "groups should return all degrees_courses groups if no year is passed as argument" do
    degree = degrees(:degree_1)
    group_ids = degree.groups.ids
    degree_course_group_ids = degree.degrees_courses.to_a.map {|degree_course| degree_course.group_id}
    assert_equal degree_course_group_ids.sort, group_ids.sort
  end

  test "groups should return degrees_courses groups of the year passed as argument" do
    year = 1
    degree = degrees(:degree_1)
    group_ids = degree.groups(year).ids
    degree_course_group_ids = degree.degrees_courses.where(year: year).to_a.map {|degree_course| degree_course.group_id}
    assert_equal degree_course_group_ids.sort, group_ids.sort
  end

end