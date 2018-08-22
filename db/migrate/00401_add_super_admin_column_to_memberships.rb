class AddSuperAdminColumnToMemberships < ActiveRecord::Migration[5.2]
    def change
      add_column :memberships, :super_admin, :boolean, :null => false, :default => false
    end
end