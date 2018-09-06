class MembersLimitExceeded < StandardError; end

class Group < ApplicationRecord
    scope :is_public, -> { where(private: false) }
    scope :with_user, -> (user) { where(id: user.group_ids) }
    scope :without_user, -> (user) { where.not(id: user.group_ids) }

    ### RELATIONS ###
    belongs_to :course, optional: true

    has_one :degree_course

    has_many :messages, :dependent => :delete_all

    has_many :memberships, :dependent => :delete_all
    has_many :members, class_name: "User", :source => :user, through: :memberships
    
    has_many :invitations, :dependent => :delete_all
    has_many :invitees, class_name: "User", through: :invitations, :source => :user

    has_many :events, :dependent => :delete_all

    ### VALIDATION ###
    validates :name, presence: true
    
    validates :max_members, numericality: { only_integer: true, greater_than_or_equal_to: -1, other_than: 0 }
    validate :max_members_is_greater_than_number_of_members

    private def max_members_is_greater_than_number_of_members
        if max_members.present? && max_members > 0 && max_members < memberships.count
            errors.add(:max_members, "must be more than the current number of members")
        end
    end

    # restituisce gli admin del gruppo
    def admins
        User.where(id: memberships.admin.pluck(:user_id)).all
    end

    # restituisce il super_admin del gruppo
    def super_admin
        User.where(id: memberships.super_admin.pluck(:user_id)).first
    end

    # restituisce true se il gruppo è ufficiale, ovvero se è il gruppo di un degree_course
    def is_official
        self.degree_course != nil
    end

    # salva il gruppo con l'utente passato come argomento come super_admin
    def save_with_admin(user)
        self.transaction do
            if self.new_record?
                self.save!
                Membership.new(group_id: self.id, user_id: user.id, super_admin: true).save!
                return true
            else
                return false
            end
        end
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
        return false
    end

    # scambia il grado di super_admin con un altro membro del gruppo
    def change_super_admin(user)
        self.transaction do
            user_membership = Membership.find_by(user_id: user.id, group_id: self.id)
            if user_membership.nil?
                # the user is not part of the group
                return false
            else
                self.memberships.super_admin.first.update_attribute(:super_admin, false)
                user_membership.update_attribute(:super_admin, true)
                return true
            end
        end
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
        return false
    end

    # restituisce i gruppi il cui nome o il cui corso di studio associato include la query passata
    def self.user_query(query)
        distinct().joins("LEFT JOIN courses ON courses.id = groups.course_id")
            .where("groups.name LIKE ? OR courses.name LIKE ?", "%#{query}%", "%#{query}%")
    end
end
