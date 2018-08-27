require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  def setup
    @attachment = Attachment.new(name: "attachment", data: "ciao", mime_type: "image/jpeg")
    @attachment.save!
  end

  test "should not save if name is not supplied" do
    @attachment.name = nil
    assert_not @attachment.save
  end

  test "should not save if data is not supplied" do
    @attachment.data = nil
    assert_not @attachment.save
  end

  test "should sanitize file name when setting file name" do
    @attachment.name = "name with spaces"
    expected = "name_with_spaces"
    assert_equal expected, @attachment.name
  end

end