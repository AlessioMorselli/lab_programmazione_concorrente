class InvitationExpired < StandardError; end
class CantAcceptInvite < StandardError; end

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
        raise InvitationExpired if self.expired?
        raise CantAcceptInvite("nessun user fornito") if self.user.nil? && user.nil?
        raise CantAcceptInvite("gli user non coincidono") if self.user != user unless user.nil? || self.user.nil?

        self.transaction do
            self.group.members << (self.user.nil? ? user : self.user)
            self.destroy unless self.user.nil?
        end
    end
end