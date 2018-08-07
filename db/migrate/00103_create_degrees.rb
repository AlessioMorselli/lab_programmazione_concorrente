class CreateDegrees < ActiveRecord::Migration[5.2]
  def change
    create_table :degrees do |t|
      t.string :name, :null => false
      t.integer :years, :null => false, :limit => 1

      t.timestamps
    end
  end
end