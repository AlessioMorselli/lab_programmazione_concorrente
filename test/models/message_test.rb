require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  fixtures :users, :attachments, :messages

  def setup
    @group = Group.new(name: "Fake group")
    assert @group.save
    @user = users(:giorgio)
    @messages = [
        Message.new(text: "ciao0", created_at: Time.now, updated_at: Time.now),
        Message.new(text: "ciao1", created_at: Time.now+1.minute, updated_at: Time.now+1.minute),
        Message.new(text: "ciao2", created_at: Time.now+5.minutes, updated_at: Time.now+5.minutes),
        Message.new(text: "ciao3", created_at: Time.now+1.hour, updated_at: Time.now+1.hour),
        Message.new(text: "ciao4", created_at: Time.now+1.hour+30.minutes, updated_at: Time.now+1.hour+30.minutes)
    ]
    @messages.each do |msg|
        msg.group_id = @group.id
        msg.user_id = @user.id
        assert msg.save
    end

    @attachment = Attachment.new(name: "ciao", mime_type: "type", data: "data")
    assert @attachment.save
  end

  test "should not save if text and attachment are not supplied" do
    message = Message.new(group_id: @group.id, user_id: @user.id)
    assert_not message.save
  end

  test "should not save if text is empty and attachment is not supplied" do
    message = Message.new(text: "   ", group_id: @group.id, user_id: @user.id)
    assert_not message.save
  end

  test "should save if only text is supplied" do
    message = Message.new(text: "ciao", group_id: @group.id, user_id: @user.id)
    assert message.save
  end

  test "should save if only attachment is supplied" do
    message = Message.new(attachment_id: @attachment.id, group_id: @group.id, user_id: @user.id)
    assert message.save
  end

  test "should save if both text and attachment are supplied" do
    message = Message.new(text: "ciao", attachment_id: @attachment.id, group_id: @group.id, user_id: @user.id)
    assert message.save
  end

  test "pinned should return pinned messages" do
    pinned_messages = [
        Message.new(text: "pinned0", pinned: true, user: @user),
        Message.new(text: "pinned1", pinned: true, user: @user),
        Message.new(text: "pinned2", pinned: true, user: @user)
    ]
    @group.messages << pinned_messages
    assert_equal pinned_messages.size, @group.messages.pinned.count
  end

  test "recent should return all group messages if no argument is passed" do
    assert_equal @messages.size, @group.messages.recent.size
  end

  test "recent should return group messages starting from the date passed" do
    index = 2
    assert_equal @messages.size-(index+1), @group.messages.recent(@messages[index].created_at).count
  end

  test "save_with_attachment should save the message with the attachment passed as argument" do
    message = Message.new(group_id: @group.id, user_id: @user.id, text: "ciao0", created_at: Time.now, updated_at: Time.now)
    attachment = Attachment.new(data: "qualcosa", mime_type: "image/jpeg", name: "image")
    assert message.save_with_attachment(attachment)
    assert_equal attachment.id, message.attachment_id
  end

  test "save_with_attachment should return false if the attachemnt is invalid" do
    message = Message.new(group_id: @group.id, user_id: @user.id, text: "ciao0", created_at: Time.now, updated_at: Time.now)
    attachment = Attachment.new(data: nil, mime_type: "image/jpeg", name: "image")
    assert_not message.save_with_attachment(attachment)
    assert_not Message.exists?(message.id)
    assert_not Attachment.exists?(attachment.id)
  end

  test "destroy should destroy the message and its attachment" do
    message = Message.where("attachment_id IS NOT NULL").first
    message_id = message.id
    attachment_id = message.attachment.id
    message.destroy!
    assert_not Message.exists?(message_id)
    assert_not Attachment.exists?(attachment_id)
  end

  test "destroy_attachment should destroy the attachment and set attachment_id to nil" do
    message = Message.where("attachment_id IS NOT NULL").first
    attachment_id = message.attachment.id
    message.destroy_attachment
    assert_not Attachment.exists?(attachment_id)
    assert message.attachment.nil?
  end

end