class AddPrimaryKeyToMemberships < ActiveRecord::Migration[5.2]
    def change
        add_column :memberships, :id, :primary_key
    end
end