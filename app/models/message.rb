class Message < ApplicationRecord
    default_scope { order(created_at: :desc) }
    
    # restituisce i messagi nella bacheca
    scope :pinned, -> { where(pinned: true) }
    
    belongs_to :user
    belongs_to :group
end