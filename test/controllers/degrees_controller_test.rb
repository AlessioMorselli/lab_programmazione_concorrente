require 'test_helper'

class DegreesControllerTest < ActionDispatch::IntegrationTest
  fixtures :degrees, :degree_courses

  test "show" do
    get degree_path(:degree_1)
    assert_response :success
  end
end
