require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :messages, :users

  test "index" do
    get group_messages_path(:group_1)
    assert_response :success
  end

  test "create" do
    assert_difference('Message.count') do
      post group_messages_path(:group_1), params: { message: {
        text: "Messaggio di prova",
        group_id: 1,
        user_id: 1
        }
      }
    end
  end

  test "update" do
    message = messages(:message_1)
 
    patch group_message_path(:group_1, message), params: { message: { text: "Messaggio modificato" } }

    message.reload
    assert_equal "Messaggio modificato", message.text
  end

  test "delete" do
    message = messages(:message_1)
    assert_difference('Message.count') do
      delete group_message_path(:group_1, message)
    end
  end

  test "pinned" do
    get group_pinned_messages(:group_1)
    assert_response :success
  end
end
