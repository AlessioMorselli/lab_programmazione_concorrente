class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, :null => false
      t.integer :max_members, :limit => 2 , :null => false, :default => -1 # no limit
      t.boolean :private, :null => false, :default => false
      t.uuid :uuid, :null => false, :default => "gen_random_uuid()"

      t.timestamps
    end
  end
end
