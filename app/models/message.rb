class Message < ApplicationRecord
    default_scope { order(created_at: :desc) }
    
    scope :pinned, -> { where(pinned: true) }
    
end