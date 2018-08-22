class AddPrimaryKeyToStudents < ActiveRecord::Migration[5.2]
    def change
        add_column :students, :id, :primary_key
    end
end