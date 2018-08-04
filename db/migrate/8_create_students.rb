class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :degrees, table_name: :students do |t|
      t.integer :year, :limit => 1, :null => false

      t.timestamps
    end
  end
end