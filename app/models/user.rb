class User < ApplicationRecord
    before_save { self.email = email.downcase }
    
    has_many :groups, through: :memberships

    has_many :messages

    has_many :invitations

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    validates :name, presence: true, length: {minimum: 3, maximum: 50 }, uniqueness: true

    validates :email, presence: true, length: {minimum: 4, maximum: 255 },
        format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
        uniqueness: { case_sensitive: false }



    # utility per creare l'hash della password 
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
end
