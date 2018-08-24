class AddPrimaryKeyToDegreesCourses < ActiveRecord::Migration[5.2]
    def change
        add_column :degrees_courses, :id, :primary_key
    end
end