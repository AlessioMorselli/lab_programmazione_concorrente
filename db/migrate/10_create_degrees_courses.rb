class CreateDegreesCourses < ActiveRecord::Migration[5.2]
  def change
    create_join_table :courses, :degrees, table_name: :degrees_courses do |t|
      t.integer :year, :limit => 1, :null => false

      t.timestamps
    end
  end
end