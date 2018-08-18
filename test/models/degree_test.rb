require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  fixtures :users, :degrees

  def setup
    #
  end

  test "groups should return degrees_courses groups" do
    degree = degrees(:degree_1)
    group_ids = degree.groups.ids
    degree_course_group_ids = degree.degrees_courses.to_a.map {|degree_course| degree_course.group_id}
    assert_equal degree_course_group_ids.sort, group_ids.sort
  end

end