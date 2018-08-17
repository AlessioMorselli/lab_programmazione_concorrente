class AddIndexToStudents < ActiveRecord::Migration[5.2]
    def change
        add_index :students, :user_id, :unique => true
    end
end