class RenameEmailConfirmInUsers < ActiveRecord::Migration[5.2]
    def change
      rename_column :users, :email_confirmed, :confirmed
      rename_column :users, :email_confirm_token, :confirm_digest
    end
end