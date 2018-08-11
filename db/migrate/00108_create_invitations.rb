class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.bigint :user_id
      t.bigint :group_id, null: false
      t.string :url_string, null: false
      t.datetime :expiration_date
      
      t.timestamps
    end
  end
end