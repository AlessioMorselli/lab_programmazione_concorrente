require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bytes = IO.read("/home/alessio/Documenti/lab_programmazione_concorrente/test/test_image.jpg").bytes
    @message = messages(:message_1)
    @group = @message.group
    @user = @message.user
    log_in_as(@user)
    set_last_message_cookies(@user, @group, DateTime.now - 1.hour)
  end

  test "should index the most recent messages" do
    get group_messages_path(group_uuid: @group.uuid)
    assert_not_empty cookies[@user.id.to_s + @group.uuid]
    assert_equal DateTime.now.to_s, cookies[@user.id.to_s + @group.uuid]
    assert_response :success
  end

  test "should send a message without attachment" do
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
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          text: "Messaggio di prova",
          group_id: @group.id,
          user_id: @user.id
        },
        # TODO: aggiungi l'allegato
        attachment: {
          name: "test_image.jpg",
          mime_type: "image/jpeg",
          data: @bytes
        }
      }
    end
  end

  test "should not send an empty message without attachment" do
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
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @group.uuid), params: {
        message: {
          # TODO: se uno non mette niente in una barra di ricerca, è nil o "" che viene passato?
          text: "",
          group_id: @group.id,
          user_id: @user.id
        },
        # TODO: aggiungi l'allegato
        attachment: {
          name: "test_image.jpg",
          mime_type: "image/jpeg",
          data: @bytes
        }
      }
    end
  end

  test "should update a message" do
    patch group_message_path(group_uuid: @group.uuid, id: @message.id), params: {
      message: { text: "Messaggio modificato" }
    }

    @message.reload
    assert_equal "Messaggio modificato", @message.text
  end

  test "should destroy a message" do
    assert_difference('Message.count', -1) do
      delete group_message_path(group_uuid: @group.uuid, id: @message.id)
    end
  end

  test "should show group pinned messages" do
    get group_pinned_messages_path(group_uuid: @group.uuid)
    assert_response :success
  end
end
