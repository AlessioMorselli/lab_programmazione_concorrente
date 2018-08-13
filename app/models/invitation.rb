class Invitation < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id

    before_save do
        self.url_string = url_string.presence || SecureRandom.urlsafe_base64
    end

    # restituisce se l'invito è ancora valido o scaduto
    def expired?
        Time.now > self.expiration_date unless self.expiration_date.nil?
    end

    def accept(user = nil)
        if self.expired? || (self.user.nil? && user.nil?) || (self.user != user unless user.nil? || self.user.nil?)
            return false
        end

        self.transaction do
            self.group.members << (self.user.nil? ? user : self.user)
            self.destroy unless self.user.nil?
        end

        return true
    end
end