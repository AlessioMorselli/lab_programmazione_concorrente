class AddPrimaryKeyToMessages < ActiveRecord::Migration[5.2]
    def change
        add_column :messages, :id, :primary_key
    end
end