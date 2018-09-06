class DegreeCourse < ApplicationRecord
    self.table_name = "degrees_courses"

    belongs_to :course
    belongs_to :degree

    belongs_to :group

    validates_presence_of :course, :degree, :group, :year

    validates :year, numericality: { only_integer: true, greater_than: 0 }
    validate :year_is_less_than_degree_years
    validates_uniqueness_of :course_id, :scope => :degree_id

    private def year_is_less_than_degree_years
        if self.degree_id.present? && self.year.present? && year > Degree.find(degree_id).years
            errors.add(:year, "must be less than degree years")
        end
    end
end
