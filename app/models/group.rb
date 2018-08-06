class Group < ApplicationRecord
    validates :name, presence: true
    validates :max_members, numericality: { only_integer: true, greater_than_or_equal_to: -1, other_than: 0 }

    has_one :course

    has_many :memberships, :dependent => :delete_all
    has_many :members, class_name: "User", through: :memberships, :source => :user

    has_many :invitations, :dependent => :delete_all
    has_many :invitees, class_name: "User", through: :invitations, :source => :user
end
