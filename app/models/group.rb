class MembersLimitExceeded < StandardError; end

class Group < ApplicationRecord
    scope :public_group, -> { where(private: false) }

    ### RELATIONS ###
    has_one :course

    has_many :messages, :dependent => :delete_all

    has_many :memberships, :dependent => :delete_all
    has_many :members, class_name: "User", :source => :user, through: :memberships, before_add: :members_size_validation
    
    has_many :invitations, :dependent => :delete_all
    has_many :invitees, class_name: "User", through: :invitations, :source => :user

    has_many :events, :dependent => :delete_all

    ### VALIDATION ###
    validates :name, presence: true
    
    validates :max_members, numericality: { only_integer: true, greater_than_or_equal_to: -1, other_than: 0 }
    validate :max_members_validation

    # solleva una eccezione che va gestita nel controller
    def members_size_validation(member)
        if max_members > 0 && members.size >= max_members
            errors.add(:base, "Unable to add member (max_members limit exceeded)")
            raise MembersLimitExceeded, "Unable to add member (max_members limit exceeded)"
        end
    end

    def max_members_validation
        if max_members.present? && max_members > 0 && members.count > max_members
            errors.add(:max_members, "must be more than the current number of members")
        end
    end
    

    def admin
        admin_membership = memberships.admin.first
        admin_membership.user unless admin_membership.nil?
    end

    def save_with_admin(user)
        if self.new_record?
            self.transaction do
                self.save!
                Membership.new(group_id: self.id, user_id: user.id, admin: true).save!
            end

            return true
        else
            return false
        end
    end

    # restituisce i gruppi il cui nome o il cui corso di studio associato include la query passata
    def self.user_query(query)
        distinct().joins("JOIN courses ON courses.id = groups.course_id").where("groups.name LIKE ? OR courses.name LIKE ?", "%#{query}%", "%#{query}%")
    end

end
