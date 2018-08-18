class Membership < ApplicationRecord
    scope :admin, -> { where(admin: true) }

    belongs_to :user
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id
    validate :memberships_number_is_less_than_max_members

    def memberships_number_is_less_than_max_members
        max_members = Group.find(group_id).max_members
        if max_members > 0 && Membership.where(group_id: group_id).count >= max_members
            errors.add(:membership, "Unable to add member (max_members limit exceeded)")
        end
    end

    def self.get_one(user, group)
        find_by(user_id: user.id, group_id: group.id)
    end
end
