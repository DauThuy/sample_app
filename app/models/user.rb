class User < ApplicationRecord
	has_many :microposts, dependent: :destroy

	attr_accessor :remember_token, :activation_token, :reset_token
	before_save :downcase_email
	before_create :create_activation_digest

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
					format: { with: VALID_EMAIL_REGEX },
					uniqueness: true
	has_secure_password

#	validates :password, presence: true, length: { minimum: 6 }
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
# 	Returns the hash digest of the given string.
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
													  BCrypt::Engine.cost
													  Crypt::Password.create(string, cost: cost)
	end

	private
	
	def downcase_email
		self.email = email.downcase
	end
	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end

	# Returns a random token.
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end


	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
		BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# Returns a random token.
	def self.new_token
		SecureRandom.urlsafe_base64
	end


	class << self
		# Returns the hash digest of the given string.
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
			BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end
		# Returns a random token.
		def new_token
			SecureRandom.urlsafe_base64
		end
	end

	# # Returns true if the given token matches the digest.
	# def authenticated?(remember_token)
	# 	BCrypt::Password.new(remember_digest).is_password?(remember_token)
	# end

	# Returns true if the given token matches the digest.
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	# Forgets a user.
	def forget
		update_attribute(:remember_digest, nil)
	end

	def activate
		update_columns(activated: FILL_IN, activated_at: FILL_IN)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_columns(reset_digest: FILL_IN, reset_sent_at: FILL_IN)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
		Micropost.where("user_id = ?", id)
	end

	def display_image
		image.variant(resize_to_limit: [500, 500])
	end

end