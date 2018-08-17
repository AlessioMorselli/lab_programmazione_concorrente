class Student < ApplicationRecord
    belongs_to :user
    belongs_to :degree

    validates_uniqueness_of :user_id
end
