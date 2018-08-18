class Student < ApplicationRecord
    belongs_to :user
    belongs_to :degree

    validates_uniqueness_of :user_id
    validates_presence_of :year
    validate :year_is_less_than_degree_years

    def year_is_less_than_degree_years
        if year.present? && year > Degree.find(degree_id).years
            errors.add(:year, "must be less than degree years")
        end
    end

end
