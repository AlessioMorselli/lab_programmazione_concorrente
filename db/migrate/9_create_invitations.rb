class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :groups, table_name: :invitations do |t|

      t.timestamps
    end
  end
end