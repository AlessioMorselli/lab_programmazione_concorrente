class Course < ApplicationRecord

    has_many :degrees_courses, class_name: "DegreeCourse"
    has_many :degrees, through: :degrees_courses

    validates_uniqueness_of :name
end
