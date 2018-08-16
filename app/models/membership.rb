class Membership < ApplicationRecord
    scope :admin, -> { where(admin: true) }

    belongs_to :user
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id

    def self.get_one(user, group)
        find_by(user_id: user.id, group_id: group.id)
    end
end
