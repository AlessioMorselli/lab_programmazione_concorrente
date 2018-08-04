class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :groups, table_name: :members do |t|
      t.boolean :admin, :null => false, :default => false

      t.timestamps
    end
  end
end