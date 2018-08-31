class Degree < ApplicationRecord

    has_many :students
    has_many :users, through: :students

    has_many :degrees_courses, class_name: "DegreeCourse", :dependent => :delete_all
    has_many :courses, :through => :degrees_courses do
        def year(year)
            where("degrees_courses.year = ?", year)
        end
    end

    def groups(year = nil)
        if year.nil?
            Group.where(id: degrees_courses.pluck(:group_id))
        else
            Group.where(id: degrees_courses.where(year: year).pluck(:group_id))
        end
    end
end
