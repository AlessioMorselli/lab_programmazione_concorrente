class User < ApplicationRecord
    attr_accessor :remember_token, :confirm_token, :reset_token

    before_save { self.email = email.downcase }
    
    has_many :memberships, :dependent => :delete_all
    has_many :groups, through: :memberships

    has_many :messages

    has_many :invitations, :dependent => :delete_all

    has_one :student
    has_one :degree, through: :student
    accepts_nested_attributes_for :student

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    validates :name, presence: true, length: {minimum: 3, maximum: 50 }, uniqueness: true

    validates :email, presence: true, length: {minimum: 4, maximum: 255 },
        format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
        uniqueness: { case_sensitive: false }

    before_create :create_confirm_digest

    # restituisce i corsi dell'utente, corto per user.degree.courses
    def courses
        degree.courses
    end

    # restituisce gli eventi dei gruppi di cui fa parte l'utente
    def events
        Event.where(group_id: groups.ids)
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Restituisce true se il token dell'attributo (:confirm, :remember) corrisponde a quello salvato nel database
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # restituisce true se il password reset è scaduto,
    # il password reset ha una durata di 2 ore
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end

    def create_confirm_digest
        self.confirm_token  = User.new_token
        self.confirm_digest = User.digest(confirm_token)
    end

    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    def activate
        update_attribute(:confirmed, true)
        update_attribute(:confirm_digest, nil)
    end

    def send_confirm_email
        UserMailer.registration_confirmation(self).deliver_now
    end

    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # restituisce i gruppi suggeriti all'utente
    # sono esclusi i gruppi privati e i gruppi di cui l'utente fa gia parte
    def suggested_groups
        Group.is_public.distinct.joins("JOIN students ON students.user_id = #{self.id}")
            .joins("JOIN degrees_courses ON degrees_courses.degree_id = students.degree_id")
            .where("groups.course_id = degrees_courses.course_id")
            .without_user(self)
    end

    # crea un nuovo gruppo con l'utente come super_admin
    def create_group(group)
        return group.save_with_admin(self);
    end



    # restituisce l'hash di una stringa 
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # restituisce un token
    def User.new_token
        SecureRandom.urlsafe_base64
    end
end
