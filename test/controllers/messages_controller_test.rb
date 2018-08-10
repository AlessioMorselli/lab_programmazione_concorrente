require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :messages, :users

  def setup
    @message = messages(:message_1)
    log_in_as(@message.user)
  end

  test "index" do
    get group_messages_path(group_uuid: @message.group.uuid)
    assert_response :success
  end

  test "create" do
    assert_difference('Message.count') do
      post group_messages_path(group_uuid: @message.group.uuid), params: { message: {
        text: "Messaggio di prova",
        group_id: @message.group.id,
        user_id: @message.user.id
        }
      }
    end
  end

  test "update" do
    # TODO: non sapendo come fare il routing, questo test è da rivedere
    patch group_message_path(group_uuid: @message.group.uuid, id: @message.id), params: { message: { text: "Messaggio modificato" } }

    @message.reload
    assert_equal "Messaggio modificato", @message.text
  end

  test "delete" do
    assert_difference('Message.count', -1) do
      delete group_message_path(group_uuid: @message.group.uuid, id: @message.id)
    end
  end

  test "pinned" do
    get group_pinned_messages(group_uuid: @message.group.uuid)
    assert_response :success
  end
end
