require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:giacomo) # membro non admin
    @message = messages(:messaggio_allegato_giacomo_samurai_1)
    @group = groups(:samurai)
    @attachment = attachments(:allegato_giacomo)

    @other_user = users(:luigi) # altro membro non admin
    @non_member = users(:aldo) # non membro
    @admin = users(:giorgio) # membro admin
  end
  
### TEST PER UTENTE LOGGATO (NON ADMIN) ###
  test 'should destroy attachment but not message' do
    log_in_as @user
    assert_difference('Attachment.count', -1) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end

    assert_redirected_to group_path(uuid: @group.uuid)
    assert_not flash.empty?
  end

  test 'should download attachment' do
    log_in_as @user
    get group_message_attachment_download_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    assert_equal @attachment.mime_type, response['Content-Type']
    assert_equal "attachment; filename=\"#{@attachment.name}\"", response["Content-Disposition"]
  end

### TEST PER UTENTE NON LOGGATO ###
  test 'should not destroy attachment if not logged in' do
    assert_difference('Attachment.count', 0) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end

    assert_redirected_to login_path
    assert_not flash.empty?
  end

  test 'should not download attachment if not logged in' do
    get group_message_attachment_download_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    assert_not_equal @attachment.mime_type, response['Content-Type']
    assert_not_equal "attachment; filename=\"#{@attachment.name}\"", response["Content-Disposition"]

    assert_redirected_to login_path
    assert_not flash.empty?
  end

### TEST PER UTENTE NON CORRETTO ###
  test 'should not destroy attachment if logged user is not the correct user' do
    log_in_as @other_user

    assert_difference('Attachment.count', 0) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UTENTE NON MEMBRO ###
  test 'should not destroy attachment if logged user is not member' do
    log_in_as @non_member

    assert_difference('Attachment.count', 0) do
      assert_difference('Message.count', 0) do
        delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
      end
    end

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

  test 'should not download attachment if logged user is not member' do
    log_in_as @non_member

    get group_message_attachment_download_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    assert_not_equal @attachment.mime_type, response['Content-Type']
    assert_not_equal "attachment; filename=\"#{@attachment.name}\"", response["Content-Disposition"]

    assert_redirected_to groups_path
    assert_not flash.empty?
  end

### TEST PER UTENTE ADMIN ###
test 'should destroy attachment if logged user is admin' do
  log_in_as @admin

  assert_difference('Attachment.count', -1) do
    assert_difference('Message.count', 0) do
      delete group_message_attachment_path(group_uuid: @group.uuid, message_id: @message.id, id: @attachment.id)
    end
  end

  assert_redirected_to group_path(uuid: @group.uuid)
  assert_not flash.empty?
end
end
