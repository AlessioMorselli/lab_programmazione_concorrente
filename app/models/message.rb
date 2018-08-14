class Message < ApplicationRecord
    default_scope { order(created_at: :desc) }
    
    # restituisce i messagi nella bacheca
    scope :pinned, -> { where(pinned: true) }
    
    belongs_to :user
    belongs_to :group

    validate :text_or_attachement_must_be_present

    def text_or_attachement_must_be_present
        unless text.present? || attachement.present?
            errors.add(:message, "Text or attachement must be present")
        end
    end

    def self.recent(from_time = nil)
        if from_time.nil?
            all
        else
            where("created_at > ?", from_time)
        end
    end
end