require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @message = messages(:messaggio_allegato_giacomo_samurai_1)
    @group = groups(:samurai)
    @attachment = attachments(:allegato_giacomo)
  end
  
  test 'should destroy attachment but not message' do
    assert_difference('Attachment.count', -1) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end

    assert_redirected_to group_path(group_uuid: @group.uuid)
    assert_not flash.empty?
  end

  test 'should download attachment' do
    get group_message_attachment_download_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    assert_equal(@attachment.mime_type, response_headers['Content-Type'])
    assert_equal("attachment; filename=\"#{@attachment.name}\"", response_headers["Content-Disposition"])
  end
end
