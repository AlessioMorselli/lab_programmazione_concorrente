class Student < ApplicationRecord
    belongs_to :user
    belongs_to :degree

    validates_uniqueness_of :user_id
    validates_presence_of :year
    validate :year_is_less_than_degree_years

    before_validation :overwrite_existing_student
    before_destroy :delete_membership_to_official_groups
    after_save :create_membership_to_official_groups

    private def year_is_less_than_degree_years
        if degree.present? && year.present? && year > Degree.find(degree_id).years
            errors.add(:year, "must be less than degree years")
        end
    end

    private def overwrite_existing_student
        current_student = Student.where(user_id: user_id).first
        if current_student != nil
            current_student.destroy
        end
    end

    private def delete_membership_to_official_groups
        self.transaction do 
            # rimuovo l'utente dai gruppi ufficiali a cui è attualmente iscritto
            degree.groups(year).each do |group|
                group.members.delete(user)
            end
        end
    end

    private def create_membership_to_official_groups
        self.transaction do
            # aggiungo l'utente ai gruppi degli insegnamenti dell'anno del corso di studio scelto
            degree.groups(year).each do |group|
                group.members << user
            end
        end
    end

end
