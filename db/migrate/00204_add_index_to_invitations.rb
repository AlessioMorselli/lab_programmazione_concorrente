class AddIndexToInvitations < ActiveRecord::Migration[5.2]
    def change
        add_index :invitations, [ :group_id, :user_id ], :unique => true
    end
end