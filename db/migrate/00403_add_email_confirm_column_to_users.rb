class AddEmailConfirmColumnToUsers < ActiveRecord::Migration[5.2]
    def change
        add_column :users, :email_confirmed, :boolean, :default => false
        add_column :users, :email_confirm_token, :string
    end
end