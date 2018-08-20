class Attachment < ApplicationRecord
    validates_presence_of :name, :data
end