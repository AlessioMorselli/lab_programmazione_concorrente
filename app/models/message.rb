class Message < ApplicationRecord
    default_scope { order(created_at: :asc) }
    
    # restituisce i messagi nella bacheca
    scope :pinned, -> { where(pinned: true) }
    # restituisce i messaggi escludendo quelli dell'utente specificato
    scope :without_user, -> (user) { where.not(user_id: user.id) }
    
    belongs_to :user
    belongs_to :group
    belongs_to :attachment, optional: true, dependent: :destroy

    validate :text_or_attachment_must_be_present
    validates_length_of :text, maximum: 1000, allow_blank: true

    private def text_or_attachment_must_be_present
        unless text.present? || attachment_id.present?
            errors.add(:message, "Text or attachment must be present")
        end
    end


    # metodo di utility per salvare un messaggio con un attachment
    # questo metodo è stato aggiunto perchè utilizzare:
    #   message.attachment = attachment
    #   message.save
    # non restituiva false nel caso in cui l'attachment non è valido
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

    # metodo di utility per rimuovere l'attachment dal messaggio
    # è stato aggiunto perchè fare message.attachment.destroy non funziona
    def destroy_attachment
        self.transaction do
            if attachment != nil
                attachment_id = attachment.id
                self.update_attribute(:attachment_id, nil)
                Attachment.destroy(attachment_id)
            end
        end
    end

    # restituisce i messaggi a partire dal tempo passato come parametro
    # o tutti se non viene pasasato nessun parametro
    def self.recent(from_time = nil)
        if from_time.nil?
            all
        else
            where("created_at > ?", from_time)
        end
    end


end