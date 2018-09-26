require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    
    @group = groups(:ninja)
    @invitation = invitations(:invito_ninja_giorgio)
    @user = users(:giorgio)

    @other_user = users(:luigi) # utente non invitato a @group
    
    @admin = users(:mario) # admin di @group
    @member = users(:aldo) # membro non admin di @group
  end

### TEST PER UN UTENTE LOGGATO E INVITATO (NON MEMBRO DEL GRUPPO) ###
  test "should index every user's invitation (not expired)" do
    log_in_as @user

    get user_invitations_path(@user)
    assert_response :success

    # Giorgio è stato invitato ai ninja
    assert_equal 1, assigns(:invitations).length
  end

  test "should index every user's invitation (expired)" do
    @invitation.update_attribute(:expiration_date, DateTime.now - 1.day)
    @invitation.reload

    log_in_as @user

    get user_invitations_path(@user)
    assert_response :success

    # Giorgio è stato invitato ai ninja, ma l'invito è scaduto
    assert_equal 0, assigns(:invitations).length
  end

  test "should show choices for an invitation" do
    log_in_as @user

    get group_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    assert_response :success
  end

  test "should accept a private invitation" do
    log_in_as @user

    assert_difference('Invitation.count', -1) do
      assert_difference('Membership.count', 1) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "should not accept a private invitation if it's expired" do
    @invitation.update_attribute(:expiration_date, DateTime.now - 1.day)
    @invitation.reload

    log_in_as @user

    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should refuse a private invitation" do
    log_in_as @user

    assert_difference('Invitation.count', -1) do
      post group_refuse_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to groups_path
  end

  test "should accept a public invitation" do
    # Creo un invito pubblico a @group, in quanto non esiste nei casi di test
    @public_invitation = Invitation.create(group_id: @group.id, user_id: nil)
    @public_invitation.reload

    log_in_as @user

    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 1) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @public_invitation.url_string)
      end
    end

    assert_redirected_to group_path(uuid: @group.uuid)
  end

  test "should not accept a public invitation if it's expired" do
    # Creo un invito pubblico scaduto a @group, in quanto non esiste nei casi di test
    @public_invitation = Invitation.create!(group_id: @group.id, user_id: nil,
                                            expiration_date: DateTime.now + 1.day)
    @public_invitation.update_attribute(:expiration_date, DateTime.now - 1.day)
    @public_invitation.reload

    log_in_as @user

    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @public_invitation.url_string)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should refuse a public invitation" do
    # Creo un invito pubblico a @group, in quanto non esiste nel db di test
    @public_invitation = Invitation.create(group_id: @group.id, user_id: nil)
    @public_invitation.reload
  
    log_in_as @user

    assert_difference('Invitation.count', 0) do
      post group_refuse_invitation_path(group_uuid: @group.uuid, url_string: @public_invitation.url_string)
    end

    assert_redirected_to groups_path
  end

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index every user's invitation if not logged in" do
    get user_invitations_path(@user)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show choices for an invitation if not logged in" do
    get group_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show a form to create a new invitation if not logged in" do
    get new_group_invitation_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new private invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @other_user.email,
        expiration_date: ""
        }
      }
    end
   
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not create a new public invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: ""
        }
      }
    end
   
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not destroy an invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      delete group_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not accept a private invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not refuse a private invitation if not logged in" do
    assert_difference('Invitation.count', 0) do
      post group_refuse_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not accept a public invitation if not logged in" do
    @public_invitation = Invitation.create!(group_id: @group.id, user_id: nil)
    @public_invitation.reload

    assert_difference('Invitation.count', 0) do
      assert_difference('Membership.count', 0) do
        post group_accept_invitation_path(group_uuid: @group.uuid, url_string: @public_invitation.url_string)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not refuse a public invitation if not logged in" do
    @public_invitation = Invitation.create(group_id: @group.id, user_id: nil)
    @public_invitation.reload

    assert_difference('Invitation.count', 0) do
      post group_refuse_invitation_path(group_uuid: @group.uuid, url_string: @public_invitation.url_string)
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not index every user's invitation if logged user is not correct" do
    log_in_as @other_user

    get user_invitations_path(@user)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE AMMINISTRATORE ###
  test "should index every group invitation" do
    log_in_as @admin

    get group_invitations_path(group_uuid: @group.uuid)
    assert_response :success

    # Nel gruppo ninja ci sono 2 inviti
    assert_equal 2, assigns(:invitations).length
  end

  test "should show a form to create a new invitation" do
    log_in_as @admin

    get new_group_invitation_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should create a new private invitation" do
    log_in_as @admin

    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @other_user.email,
        expiration_date: ""
        }
      }
    end
  
    assert_redirected_to group_invitations_path(group_uuid: @group.uuid)
    assert_equal 1, ActionMailer::Base.deliveries.size, "Mail non inviata"
  end

  test "should not create a new private invitation if an identical invitation exists" do
    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @user.email,
        expiration_date: ""
        }
      }
    end
  
    assert_not flash.empty?
  end

  test "should not create a new private invitation if email is wrong" do
    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "wrong email",
        expiration_date: ""
        }
      }
    end
  
    assert_not flash.empty?
  end

  test "should not create a new private invitation if invited user is already member" do
    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @member.name,
        expiration_date: ""
        }
      }
    end
  
    assert_redirected_to new_group_invitation_path(group_uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should create a new public invitation" do
    log_in_as @admin

    assert_difference('Invitation.count') do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: ""
        }
      }
    end
  
    assert_redirected_to group_invitations_path(group_uuid: @group.uuid)
  end

  test "should not create a new public invitation if an identical invitation exists" do
    @public_invitation = Invitation.create(group_id: @group.id, user_id: nil)
    @public_invitation.reload

    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: ""
        }
      }
    end
  
    assert_not flash.empty?
  end

  test "should destroy an invitation" do
    log_in_as @admin

    assert_difference('Invitation.count', -1) do
      delete group_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    end
  end

  test "should update existing public invitation if it's expired" do
    # Creo un invito scaduto
    @public_invitation = Invitation.create!(group_id: @group.id, user_id: nil,
                                            expiration_date: DateTime.now + 1.day)
    @public_invitation.update_attribute(:expiration_date, DateTime.now - 1.day)

    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: DateTime.now + 1.month
        }
      }
    end
    # @public_invitation.reload

    # assert_equal DateTime.now + 1.month, @public_invitation.expiration_date
  end

  test "should update existing private invitation if it's expired" do
    # Creo un invito scaduto
    @public_invitation = Invitation.create!(group_id: @group.id, user_id: @other_user.id,
                                            expiration_date: DateTime.now + 1.day)
    @public_invitation.update_attribute(:expiration_date, DateTime.now - 1.day)

    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @other_user.email,
        expiration_date: DateTime.now + 1.month
        }
      }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size, "Mail non inviata"
  end

  test "should not create a new public invitation with expiration date before now" do
    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: DateTime.now - 1.day
        }
      }
    end
  
    assert_not flash.empty?
  end

  test "should not create a new private invitation with expiration date before now" do
    log_in_as @admin

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @other_user.email,
        expiration_date: DateTime.now - 1.day
        }
      }
    end
  
    assert_not flash.empty?
  end

### TEST PER UN UTENTE MEMBRO NON AMMINISTRATORE ###
  test "should index every group invitation if logged user is not admin" do
    log_in_as @member

    get group_invitations_path(group_uuid: @group.uuid)
    
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not show a form to create a new invitation if logged user is not admin" do
    log_in_as @member

    get new_group_invitation_path(group_uuid: @group.uuid)
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not create a new private invitation if logged user is not admin" do
    log_in_as @member

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: @other_user.email,
        expiration_date: ""
        }
      }
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not create a new public invitation if logged user is not admin" do
    log_in_as @member

    assert_difference('Invitation.count', 0) do
      post group_invitations_path(group_uuid: @group.uuid), params: { invitation: {
        user: "",
        expiration_date: ""
        }
      }
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not destroy an invitation if logged user is not admin" do
    log_in_as @member

    assert_difference('Invitation.count', 0) do
      delete group_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end
end
