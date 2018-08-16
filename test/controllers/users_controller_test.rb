require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user_1)
  end

  test "should show signup page" do
    get signup_path
    assert_response :success
  end

  test "should register a new user" do
    assert_difference('User.count') do
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

  test "should show form to edit a user" do
    get edit_user_path(@user)
    assert_response :success
  end

  test "should update a user" do
    patch user_path(@user), params: { user: {
      name: "NewName",
      # TODO: Perchè devo mettere la password? Problemi con le fixture?
      password: "ciaone"
      }
    }
  
    assert_redirected_to groups_path

    @user.reload
    assert_equal "NewName", @user.name
  end

  test "should destroy a user" do
    assert_difference('User.count', -1) do
      delete user_path(@user)
    end
    
    assert_redirected_to login_path
  end
end
