# == Schema Information
#
# Table name: managers
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_managers_on_email  (email) UNIQUE
#

class Manager < ApplicationRecord
  attr_reader :password

  has_one :key, as: :identity, dependent: :destroy
  has_many :community_managers
  has_many :communities, through: :community_managers

  before_save { self.email = email.downcase }
  before_save :update_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }


  # PASSWORD STUFF
  validate do |record|
    record.errors.add(:password, :blank) unless record.password_digest.present?
  end

  def authenticate(unencrypted_password)
    SCrypt::Password.new(password_digest).is_password?(unencrypted_password) && self
  end

  def password=(unencrypted_password)
    if unencrypted_password.nil?
      self.password_digest = nil
    elsif !unencrypted_password.empty?
      @password = unencrypted_password
      self.password_digest = SCrypt::Password.create(unencrypted_password)
    end
  end

  def update_token
    if password_digest_changed?
      if persisted?
        key.set_token
      else
        self.build_key
      end
    end
  end
end
