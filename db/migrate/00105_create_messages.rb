class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :groups, table_name: :messages do |t|
      t.text :text, :null => false, :default => ""
      t.boolean :pinned, :null => false, :default => false
      t.binary :attachement, :null => true

      t.timestamps
    end
  end
end
