require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :students, :memberships, :events, :groups

  test "new" do
    get signup_path
    assert_response :success
  end

  test "create" do
    assert_difference('Group.count') do
      post signup_path, params: { user: {
        name: "CoolName",
        password: "CoolPassword",
        email: "cool.email@cool.it",
        degree_id: 1,
        year: 2
        }
      }
    end
   
    assert_redirected_to groups_path
  end

  test "edit" do
    get edit_user_path(:user_1)
    assert_response :success
  end

  test "update" do
    user = users(:user_1)
 
    patch user_path(user), params: { user: { name: "NewName" } }
  
    assert_redirected_to groups_path

    user.reload
    assert_equal "NewName", user.name
  end

  test "delete" do
    user = users(:user_1)
    assert_difference('User.count') do
      delete user_path(user)
    end
    
    assert_redirected_to login_path
  end
end
