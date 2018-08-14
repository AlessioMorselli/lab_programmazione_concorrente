require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  fixtures :groups, :memberships, :users, :attachments

  def setup
    @message = messages(:message_with_attachments_1)
    @group = @message.group
    @attachment = @message.attachment
  end
  
  test 'should destroy attachment but not message' do
    assert_difference('Attachment.count', -1) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end
  end

  test 'should download attachment' do
    get group_message_attachment_download_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    assert_equal(@attachment.type, response_headers['Content-Type'])
    assert_equal("attachment; filename=\"#{@attachment.name}\"", response_headers["Content-Disposition"])
  end
end
