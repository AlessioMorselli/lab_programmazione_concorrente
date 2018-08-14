class AddAttachmentReferenceToMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :attachment, foreign_key: true
  end
end