require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:luigi)
    @other_user = users(:mario)
  end

### TEST DI REGISTRAZIONE ###
  test "should show signup page" do
    get signup_path
    assert_response :success
  end

  test "should register a new user" do
    assert_difference('User.count') do
      assert_difference('Student.count') do
        post signup_path, params: { user: {
          name: "CoolName",
          password: "CoolPassword",
          email: "cool.email@cool.it",
          degree_id: 1,
          year: 2
          }
        }
      end
    end
   
    assert_not flash.empty?
    assert_redirected_to landing_path
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should show form to edit a user" do
    log_in_as @user

    get edit_user_path(@user)
    assert_response :success
  end

  test "should update a user" do
    log_in_as @user
    
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

  # test "should destroy a user" do
  #   log_in_as @user
    
  #   assert_difference('User.count', -1) do
  #     assert_difference('Invitation.count', -1 * @user.invitations.count) do
  #       assert_difference('Student.count', -1) do
  #         delete user_path(@user)
  #       end
  #     end
  #   end
    
  #   assert_redirected_to login_path
  # end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not show form to edit a user if not logged in" do
    get edit_user_path(@user)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not update a user if not logged in" do
    name = @user.name
    patch user_path(@user), params: { user: {
      name: "NewName",
      # TODO: Perchè devo mettere la password? Problemi con le fixture?
      password: "ciaone"
      }
    }
  
    assert_redirected_to login_path
    assert_not flash.empty?

    @user.reload
    assert_equal name, @user.name
  end

  # test "should not destroy a user if not logged in" do
  #   assert_difference('User.count', 0) do
  #     delete user_path(@user)
  #   end
    
  #   assert_redirected_to login_path
  #   assert_not flash.empty?
  # end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not show form to edit a user if logged user is not correct" do
    log_in_as @other_user

    get edit_user_path(@user)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should update a user if logged user is not correct" do
    log_in_as @other_user
    
    name = @user.name
    patch user_path(@user), params: { user: {
      name: "NewName",
      # TODO: Perchè devo mettere la password? Problemi con le fixture?
      password: "ciaone"
      }
    }
  
    assert_redirected_to groups_path
    assert_not flash.empty?

    @user.reload
    assert_equal name, @user.name
  end

  # test "should not destroy a user if logged user is not correct" do
  #   log_in_as @other_user
    
  #   assert_difference('User.count', 0) do
  #     delete user_path(@user)
  #   end
    
  #   assert_redirected_to groups_path
  #   assert_not flash.empty?
  # end
end
