class Invitation < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id

    before_save do
        self.url_string = url_string.presence || SecureRandom.urlsafe_base64
    end
end