class User < ApplicationRecord
    attr_accessor :remember_token, :confirm_token, :reset_token

    before_save { self.email = email.downcase }
    
    has_many :memberships, :dependent => :delete_all
    has_many :groups, through: :memberships

    has_many :messages

    has_many :invitations, :dependent => :delete_all

    has_one :student
    has_one :degree, through: :student

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    validates :name, presence: true, length: {minimum: 3, maximum: 50 }, uniqueness: true

    validates :email, presence: true, length: {minimum: 4, maximum: 255 },
        format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
        uniqueness: { case_sensitive: false }

    before_create :create_confirm_digest


    def courses
        degree.courses
    end

    def events
        Event.where(group_id: groups.ids)
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

    # Returns true if a password reset has expired.
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
        self.confirmed = true
        self.confirm_digest = nil
        save
    end

    def send_confirm_email
        UserMailer.registration_confirmation(self).deliver_now
    end

    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
      end


    def suggested_groups
        Group.is_public.distinct.joins("JOIN students ON students.user_id = #{self.id}")
            .joins("JOIN degrees ON degrees.id = students.degree_id")
            .joins("JOIN degrees_courses ON degrees_courses.degree_id = degrees.id")
            .where("groups.course_id = degrees_courses.course_id")
            .without_user(self)
    end

    def create_group(group)
        return group.save_with_admin(self);
    end
end
