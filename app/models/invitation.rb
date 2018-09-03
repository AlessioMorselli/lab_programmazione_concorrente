class Invitation < ApplicationRecord
    scope :not_expired, -> { where("expiration_date > ?", Time.now).or(self.where("expiration_date IS NULL")) }
    scope :expired, -> { where("expiration_date <= ?", Time.now) }

    belongs_to :user, optional: true
    belongs_to :group

    validates_uniqueness_of :user_id, :scope => :group_id
    validate :expiration_date_is_not_before_now

    before_validation :overwrite_existing_invitation

    before_save do
        self.url_string = url_string.presence || SecureRandom.urlsafe_base64
    end

    def overwrite_existing_invitation
        invitation = Invitation.where(group_id: group_id).where(user_id: user_id).first
        if invitation != nil && invitation.is_expired?
            # c'è già un invito ma è scaduto, lo sovrascrivo
            invitation.destroy
        end
    end

    def expiration_date_is_not_before_now
        if self.expiration_date != nil && self.expiration_date < Time.now
            errors.add(:expiration_date, "cannot be before now") 
        end
    end

    # restituisce se l'invito è scaduto
    def is_expired?
        Time.now > self.expiration_date unless self.expiration_date.nil?
    end

    def is_private?
        user != nil
    end

    def accept(user = nil)
        if self.is_expired? || (self.user.nil? && user.nil?) || (self.user != user unless user.nil? || self.user.nil?)
            return false
        end

        self.transaction do
            self.group.members << (self.user.nil? ? user : self.user)
            self.destroy unless self.user.nil?
        end

        return true
    end
end