class AddGroupReferenceToDegreesCourses < ActiveRecord::Migration[5.2]
  def change
    add_reference :degrees_courses, :group, foreign_key: true
  end
end