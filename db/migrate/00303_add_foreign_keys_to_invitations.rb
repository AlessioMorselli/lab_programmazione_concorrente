class AddForeignKeysToInvitations < ActiveRecord::Migration[5.2]
    def change
        add_foreign_key :invitations, :groups
        add_foreign_key :invitations, :users
    end
end