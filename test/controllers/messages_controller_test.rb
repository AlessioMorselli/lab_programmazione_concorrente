require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @message = messages(:message_1)
    @group = @message.group
    @user = @message.user
    set_last_message_cookies(@user, @group, DateTime.now - 1.hour)
    
    @message_with_attachment = messages(:message_with_attachments_1)
    @group_with_attachment = @message_with_attachment.group
    @user_with_attachment = @message_with_attachment.user
  end

  ### TEST PER UN UTENTE LOGGATO ###
  test "should index the most recent messages" do
    log_in_as(@user)

    get group_messages_path(group_uuid: @group.uuid)
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success
  end

  test "should send a message without attachment" do
    log_in_as(@user)
    
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: {
          name: nil,
          mime_type: nil,
          data: nil
        }
      }
    end
  end

  test "should send a message with attachment" do
    log_in_as(@user)

    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: {
          name: "test_image.jpg",
          mime_type: "image/jpeg",
          data: "qualcosa"
        }
      }
    end
  end

  test "should not send an empty message without attachment" do
    log_in_as(@user)
  
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          # TODO: se uno non mette niente in una barra di ricerca, è nil o "" che viene passato?
          text: "",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: {
          name: nil,
          mime_type: nil,
          data: nil
        }
      }
    end
  end

  test "should send an empty message with attachment" do
    log_in_as(@user)

    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          # TODO: se uno non mette niente in una barra di ricerca, è nil o "" che viene passato?
          text: "",
          group_id: @group.id,
          user_id: @user.id
        },
        attachment: {
          name: "test_image.jpg",
          mime_type: "image/jpeg",
          data: "qualcosa"
        }
      }
    end
  end

  test "should update a message" do
    log_in_as(@user)

    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    @message.reload
    assert_equal "Messaggio modificato", @message.text
  end

  test "should not update a message if i delete its text" do
    log_in_as(@user)

    text = @message.text
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "" }
    }

    @message.reload
    assert_equal text, @message.text
  end

  test "should destroy a message without an attachment" do
    log_in_as(@user)

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', 0) do
        delete group_message_path(group_uuid: @group.uuid, id: @message.id)
      end
    end

    assert_not flash.empty?
  end

  test "should destroy a message with attachment" do
    log_in_as(@user_with_attachment)

    assert_difference('Message.count', -1) do
      assert_difference('Attachment.count', -1) do
        delete group_message_path(group_uuid: @group_with_attachment.uuid, id: @message_with_attachment.id)
      end
    end

    assert_not flash.empty?
  end

  test "should show group pinned messages" do
    log_in_as(@user)

    get group_pinned_messages_path(group_uuid: @group.uuid)
    assert_response :success
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
        attachment: {
          name: nil,
          mime_type: nil,
          data: nil
        }
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
end
