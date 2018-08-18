class DegreeCourse < ApplicationRecord
    self.table_name = "degrees_courses"

    belongs_to :course
    belongs_to :degree

    belongs_to :group

    validates_presence_of :year
    validate :year_is_less_than_degree_years

    def year_is_less_than_degree_years
        if year.present? && year > Degree.find(degree_id).years
            errors.add(:year, "must be less than degree years")
        end
    end
end
