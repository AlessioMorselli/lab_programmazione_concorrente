class User < ApplicationRecord
    attr_accessor :remember_token

    before_save { self.email = email.downcase }
    
    has_many :memberships, :dependent => :delete_all
    has_many :groups, class_name: "Group", :source => :group, through: :memberships

    has_many :messages

    has_many :invitations, :dependent => :delete_all

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    validates :name, presence: true, length: {minimum: 3, maximum: 50 }, uniqueness: true

    validates :email, presence: true, length: {minimum: 4, maximum: 255 },
        format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
        uniqueness: { case_sensitive: false }


    # restituisce l'hash di una stringa 
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # restituisce un remember token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Restituisce true se il remember token corrisponde a quello salvato nel database
    def authenticated?(remember_token)
        remember_digest ? BCrypt::Password.new(remember_digest).is_password?(remember_token) : false
    end

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end
end
