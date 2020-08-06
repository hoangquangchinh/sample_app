class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  PERMITTED_PARAMS = %i(name email password password_validation).freeze
  RESET_PASSWORD_PARAMS = %i(password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true,
    length: {maximum: Settings.validate.user.name_maxlength}
  validates :email, presence: true,
    length: {maximum: Settings.validate.user.email_maxlength},
    format: {with: Settings.validate.user.email_format}, uniqueness: true
  validates :password, presence: true,
    length: {minimum: Settings.validate.user.password_minlength},
    allow_nil: true

  before_save :email.downcase
  has_secure_password

  scope :is_activated, ->{where activated: true}

  def email_downcase
    email.downcase!
  end

  def new_token
    SecureRandom.urlsafe_base64
  end

  class << self
    def digest string
      cost =
        if ActiveModel::SecurePassword.min_cost
          BCrypt::Engine::MIN_COST
        else
          BCrypt::Engine.cost
        end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.time.expired.hours.ago
  end

  def feed
    microposts
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
