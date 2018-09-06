class Membership < ApplicationRecord
    # restituisce la membeship degli admin
    scope :admin, -> { where(admin: true) }
    # restituisce la membeship del super_admin
    scope :super_admin, -> { where(super_admin: true) }

    belongs_to :user
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id
    validate :memberships_number_is_less_than_max_members
    validate :super_admin_per_group_is_one

    before_save :set_super_admin_as_admin

    # il super_admin viene automaticamente messo come admin
    private def set_super_admin_as_admin
        if self.super_admin == true
            self.admin = true
        end
    end

    private def memberships_number_is_less_than_max_members
        max_members = Group.find(self.group_id).max_members
        if max_members > 0 && Membership.where(group_id: group_id).count >= max_members
            errors.add(:membership, "Unable to add member (max_members limit exceeded)")
        end
    end

    private def super_admin_per_group_is_one
        super_admins_count = Membership.where(group_id: group_id).where(super_admin: true).count
        if self.super_admin == true && super_admins_count == 1
            errors.add(:membership, "Every group must have only one super admin")
        end
    end


    # metodo di classe per ottenere una memebership dato user e group
    def self.get_one(user, group)
        find_by(user_id: user.id, group_id: group.id)
    end

    
end
