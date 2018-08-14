require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @group = Group.new(name: "Fake group")
    @group.save
    @messages = [
        Message.new(text: "ciao0", created_at: Time.now, updated_at: Time.now),
        Message.new(text: "ciao1", created_at: Time.now+1.minute, updated_at: Time.now+1.minute),
        Message.new(text: "ciao2", created_at: Time.now+5.minutes, updated_at: Time.now+5.minutes),
        Message.new(text: "ciao3", created_at: Time.now+1.hour, updated_at: Time.now+1.hour),
        Message.new(text: "ciao4", created_at: Time.now+1.hour+30.minutes, updated_at: Time.now+1.hour+30.minutes)
    ]
    @messages.each do |msg|
        msg.group_id = @group.id
        msg.user_id = users(:user_1).id
        msg.save
    end
  end

  test "should not save if text and attachement are not supplied" do
    message = Message.new(group_id: @group.id, user_id: users(:user_1).id)
    assert_not message.save
  end

  test "should not save if text is empty and attachement is not supplied" do
    message = Message.new(text: "   ", group_id: @group.id, user_id: users(:user_1).id)
    assert_not message.save
  end

  test "should save if only text is supplied" do
    message = Message.new(text: "ciao", group_id: @group.id, user_id: users(:user_1).id)
    assert message.save
  end

  test "should save if only attachement is supplied" do
    message = Message.new(attachement: 1, group_id: @group.id, user_id: users(:user_1).id)
    assert message.save
  end

  test "should save if both text and attachement are supplied" do
    message = Message.new(text: "ciao", attachement: 1, group_id: @group.id, user_id: users(:user_1).id)
    assert message.save
  end

  test "pinned should return pinned messages" do
    pinned_messages = [
        Message.new(text: "pinned0", pinned: true, user: users(:user_1)),
        Message.new(text: "pinned1", pinned: true, user: users(:user_1)),
        Message.new(text: "pinned2", pinned: true, user: users(:user_1))
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

end