require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @group = groups(:cavalieri)

    @user = users(:aldo) # non admin

    @non_member = users(:luigi)

    @admin = users(:mario)
    @super_admin = users(:giacomo)

    set_last_message_cookies(@user, @group, DateTime.now - 1.hour)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should index suggested groups" do
    log_in_as @user

    get groups_path
    assert_response :success

    # Per Aldo non ci sono gruppi suggeriti
    # I cavalieri studiano analisi 2 (ma Aldo è già suo membro), mentre i samurai studiano
    # meccatronica, che fa parte del corso di studi di Aldo (il prossimo anno)
    assert_equal 1, assigns(:groups).length

    # assert_template :public_groups_list
  end

  test "should index searched groups (private, name)" do
    log_in_as @user

    get groups_path, params: {query: "pirati"}
    assert_response :success

    # Vi è un solo gruppo denominato "pirati", ma è privato, non deve risultare
    assert_equal 0, assigns(:groups).length
  end

  test "should index searched groups (public, name)" do
    log_in_as @user

    get groups_path, params: {query: "samurai"}
    assert_response :success

    # Vi è un solo gruppo denominato "samurai"
    assert_equal 1, assigns(:groups).length
  end

  test "should index searched groups (course)" do
    log_in_as @user

    get groups_path, params: {query: "meccatronica"}
    assert_response :success

    # Vi sono due gruppi che studia meccatronica, ma uno è privato
    assert_equal 1, assigns(:groups).length
  end

  test "should index searched groups (course) with query as array" do
    log_in_as @user

    get groups_path, params: {query: ["meccatronica", "dato in più"]}
    assert_response :success

    # Vi sono due gruppi che studia meccatronica, ma uno è privato
    assert_equal 1, assigns(:groups).length
  end

  test "should show a group chat" do
    log_in_as @user

    get group_path(uuid: @group.uuid)
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success
  end

  test "should show a form to create a new group" do
    log_in_as @user

    get new_group_path
    assert_response :success
  end

  test "should create a new group with a super admin member" do
    log_in_as @user
    
    assert_difference('Group.count') do
      assert_difference('Membership.count') do
        post groups_path, params: { group: {
          name: "I ciccioni",
          max_members: 10,
          private: true,
          course_id: nil
          }
        }
      end
    end

    assert_redirected_to group_path(uuid: Group.find_by_name("I ciccioni").uuid)
  end

  test "should not create a new group with zero max members" do
    log_in_as @user

    assert_difference('Group.count', 0) do
      assert_difference('Membership.count', 0) do
        post groups_path, params: { group: {
          name: "I ciccioni",
          max_members: 0,
          private: true,
          course_id: nil
          }
        }
      end
    end

    assert_not flash.empty?
  end

  test "should not show a form to edit a group if logged user is not super admin" do
    log_in_as @user

    get edit_group_path(uuid: @group.uuid)
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not update a group if logged user is not super admin" do 
    log_in_as @user
    name = @group.name

    patch group_path(uuid: @group.uuid), params: { group: { name: "Nuovi ciccioni" } }

    @group.reload
    assert_equal name, @group.name

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not destroy a group if logged user is not super admin" do
    log_in_as @user

    assert_difference('Group.count', 0) do
      assert_difference('Message.count', 0) do
        assert_difference('Event.count', 0) do
          assert_difference('Membership.count', 0) do
            assert_difference('Invitation.count', 0) do
              delete group_path(uuid: @group.uuid)
            end
          end
        end
      end
    end
    
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index groups if not logged in" do
    get groups_path

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a group chat if not logged in" do
    get group_path(uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a form to create a new group if not logged in" do
    get new_group_path

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new group with an admin member if not logged in" do
    assert_difference('Group.count', 0) do
      assert_difference('Membership.count', 0) do
        post groups_path, params: { group: {
          name: "I ciccioni",
          max_members: 10,
          private: true,
          course_id: nil
          }
        }
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a form to edit a group if not logged in" do
    get edit_group_path(uuid: @group.uuid)

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not update a group if not logged in" do
    name = @group.name
    patch group_path(uuid: @group.uuid), params: { group: { name: "Nuovi ciccioni" } }

    assert_redirected_to login_path
    assert_not flash.empty?

    @group.reload
    assert_equal name, @group.name
  end

  test "should not destroy a group if not logged in" do
    assert_difference('Group.count', 0) do
      assert_difference('Message.count', 0) do
        assert_difference('Event.count', 0) do
          assert_difference('Membership.count', 0) do
            assert_difference('Invitation.count', 0) do
              delete group_path(uuid: @group.uuid)
            end
          end
        end
      end
    end
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON MEMBRO ###
  test "should not show a group chat if logged user is not member" do
    log_in_as @non_member

    get group_path(uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE SUPER AMMINISTRATORE ###
  test "should show a form to edit a group if logged user is super admin" do
    log_in_as @super_admin

    get edit_group_path(uuid: @group.uuid)
    assert_response :success
  end

  test "should update a group if logged user is super admin" do 
    log_in_as @super_admin

    patch group_path(uuid: @group.uuid), params: { group: { name: "Nuovi ciccioni" } }

    assert_redirected_to group_path(uuid: @group.uuid)

    @group.reload
    assert_equal "Nuovi ciccioni", @group.name
  end

  test "should not update a group with zero max members" do
    log_in_as @super_admin

    max_members = @group.max_members
    patch group_path(uuid: @group.uuid), params: { group: { max_members: 0 } }

    assert_not flash.empty?

    @group.reload
    assert_equal max_members, @group.max_members
  end

  test "should destroy a group with its messages, event, members and invitations if logged user is super admin" do
    log_in_as @super_admin

    assert_difference('Group.count', -1) do
      assert_difference('Message.count', (-1) * @group.messages.count) do
        assert_difference('Event.count', (-1) * @group.events.count) do
          assert_difference('Membership.count', (-1) * @group.memberships.count) do
            assert_difference('Invitation.count', (-1) * @group.invitations.count) do
              delete group_path(uuid: @group.uuid)
            end
          end
        end
      end
    end
    
    assert_redirected_to groups_path
end
end
