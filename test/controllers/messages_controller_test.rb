require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @message = messages(:messaggio_giovanni_cavalieri_1)
    @group = groups(:cavalieri)
    @user = users(:giovanni)
    set_last_message_cookies(@user, @group, DateTime.now - 1.hour)

    @other_user = users(:aldo)
    
    @message_with_attachment = messages(:messaggio_allegato_mario_cavalieri_1)
    @user_with_attachment = users(:mario)

    @message_pinned = messages(:messaggio_pinnato_giacomo_cavalieri_1)

    @non_member = users(:giorgio)

    @admin = users(:giacomo)
  end

### TEST PER UN UTENTE LOGGATO ###
  test "should index the most recent messages" do
    log_in_as @user

    get group_messages_path(group_uuid: @group.uuid)
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success

    # I messaggi più recenti per Giovanni (quindi mandati nell'ultima ora) nel gruppo dei cavalieri sono 8
    assert_equal 8, assigns(:messages).length
  end

  test "should index messages of last day" do
    log_in_as @user

    get group_messages_path(group_uuid: @group.uuid),
        params: {from: (DateTime.now - 1.day).to_s}
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success

    # I messaggi dell'ultimo giorno per Giovanni nel gruppo dei cavalieri sono 14
    assert_equal 14, assigns(:messages).length
  end

  test "should index messages of last day with from as array" do
    log_in_as @user

    get group_messages_path(group_uuid: @group.uuid),
        params: {from: [(DateTime.now - 1.day).to_s, "dato in più"]}
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success

    # I messaggi dell'ultimo giorno per Giovanni nel gruppo dei cavalieri sono 14
    assert_equal 14, assigns(:messages).length
  end

  test "should send a message without attachment" do
    log_in_as @user
    
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: nil
      }
    end
  end

  test "should send a message with attachment" do
    log_in_as @user

    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: fixture_file_upload('files/test_image.jpg','image/jpeg')
      }
    end
  end

  test "should not send an empty message without attachment" do
    log_in_as @user
  
    assert_difference('Message.count', 0) do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          # TODO: se uno non mette niente in una barra di ricerca, è nil o "" che viene passato?
          text: "",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: nil
      }
    end
  end

  test "should send an empty message with attachment" do
    log_in_as @user

    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          # TODO: se uno non mette niente in una barra di ricerca, è nil o "" che viene passato?
          text: "",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: fixture_file_upload('files/test_image.jpg','image/jpeg')
      }
    end
  end

  test "should update a message" do
    log_in_as @user

    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    @message.reload
    assert_equal "Messaggio modificato", @message.text
  end

  test "should not update a message if its text is deleted" do
    log_in_as @user

    text = @message.text
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "" }
    }

    @message.reload
    assert_equal text, @message.text
  end

  test "should destroy a message without an attachment" do
    log_in_as @user

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_not flash.empty?
  end

  test "should destroy a message with attachment" do
    log_in_as @user_with_attachment

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', -1) do
        delete group_message_path(group_uuid: @group.uuid, id: @message_with_attachment.id)
      end
    end

    assert_not flash.empty?
  end

  test "should show group pinned messages" do
    log_in_as @user

    get group_pinned_messages_path(group_uuid: @group.uuid)
    assert_response :success
  end

  test "should not pin a message if logged user is not admin" do
    log_in_as @user

    patch group_pin_message_path(group_uuid: @group.uuid, id: @message.id)

    assert_equal false, @message.pinned
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test "should not unpin a message if logged user is not admin" do
    log_in_as @user

    patch group_pin_message_path(group_uuid: @group.uuid, id: @message_pinned.id)

    assert_equal true, @message_pinned.pinned
    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end 

### TEST PER UN UTENTE NON LOGGATO ###
  test "should not index the most recent messages if not logged in" do
    get group_messages_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not send a message if not logged in" do
    assert_difference('Message.count', 0) do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: nil
      }
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end
  
  test "should not update a message if not logged in" do
    text = @message.text
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    assert_redirected_to login_path
    assert_not flash.empty?

    @message.reload
    assert_equal text, @message.text
  end

  test "should not destroy a message if not logged in" do
    assert_difference('Message.count', 0) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test "should not show group pinned messages if logged in" do
    get group_pinned_messages_path(group_uuid: @group.uuid)
    
    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON CORRETTO ###
  test "should not update a message if logged user is not correct" do
    log_in_as @other_user

    text = @message.text
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    @message.reload
    assert_equal text, @message.text

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not destroy a message if logged user is not correct" do
    log_in_as @other_user

    assert_difference('Message.count', 0) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE NON MEMBRO ###
  test "should not index the most recent messages if logged user is not member" do
    log_in_as @non_member

    get group_messages_path(group_uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not send a message if logged user is not member" do
    log_in_as @non_member
    
    assert_difference('Message.count', 0) do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: nil
      }
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not update a message if logged user is not a member" do
    log_in_as @non_member

    text = @message.text
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    @message.reload
    assert_equal text, @message.text

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not destroy a message if logged user is not a member" do
    log_in_as @non_member

    assert_difference('Message.count', 0) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test "should not show group pinned messages if logged user is not member" do
    log_in_as @non_member

    get group_pinned_messages_path(group_uuid: @group.uuid)
    
    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UN UTENTE AMMINISTRATORE ###
  test "should destroy another user's message without an attachment if logged user is admin" do
    log_in_as @admin

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_not flash.empty?
  end

  test "should destroy another user's message with attachment if logged user is admin" do
    log_in_as @admin

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', -1) do
        delete group_message_path(group_uuid: @group.uuid, id: @message_with_attachment.id)
      end
    end
    
    assert_not flash.empty?
  end

  test "should pin a message if logged user is admin" do
    log_in_as @admin

    patch group_pin_message_path(group_uuid: @group.uuid, id: @message.id)

    @message.reload
    assert_equal true, @message.pinned
    assert_not flash.empty?
  end

  test "should unpin a message if logged user is admin" do
    log_in_as @admin

    patch group_pin_message_path(group_uuid: @group.uuid, id: @message_pinned.id)

    @message_pinned.reload
    assert_equal false, @message_pinned.pinned
    assert_not flash.empty?
  end 
end
