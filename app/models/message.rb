class Message < ApplicationRecord
    default_scope { order(created_at: :desc) }
    
    # restituisce i messagi nella bacheca
    scope :pinned, -> { where(pinned: true) }
    
    belongs_to :user
    belongs_to :group
    belongs_to :attachment, optional: true, dependent: :destroy

    validate :text_or_attachment_must_be_present

    def text_or_attachment_must_be_present
        unless text.present? || attachment_id.present?
            errors.add(:message, "Text or attachment must be present")
        end
    end

    def self.recent(from_time = nil)
        if from_time.nil?
            all
        else
            where("created_at > ?", from_time)
        end
    end

    def save_with_attachment(attachment = nil)
        self.transaction do
            if attachment != nil
                attachment.save!
                self.attachment_id = attachment.id
            end
            self.save!

            return true
        end
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
        return false
    end

end