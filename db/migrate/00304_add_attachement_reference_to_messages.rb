class AddAttachementReferenceToMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :attachement, foreign_key: true
  end
end