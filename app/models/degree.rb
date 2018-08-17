class Degree < ApplicationRecord

    has_many :students
    has_many :users, through: :students

    has_many :degrees_courses, class_name: "DegreeCourse", :dependent => :delete_all
    has_many :courses, through: :degrees_courses
end
