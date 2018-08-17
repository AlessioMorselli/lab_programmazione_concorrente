class DegreeCourse < ApplicationRecord
    self.table_name = "degrees_courses"

    belongs_to :course
    belongs_to :degree

    belongs_to :group
end
