class AddIndexToMemberships < ActiveRecord::Migration[5.2]
    def change
        add_index :memberships, [ :group_id, :user_id ], :unique => true
    end
end