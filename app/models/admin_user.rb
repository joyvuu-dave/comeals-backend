# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  superuser              :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :bigint           not null
#
# Indexes
#
#  index_admin_users_on_community_id          (community_id)
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :community

  has_many :bills, through: :community
  has_many :units, through: :community
  has_many :meals, through: :community
  has_many :reconciliations, through: :community
  has_many :residents, through: :community
  has_many :units, through: :community
  has_many :rotations, through: :community
  has_many :events, through: :community
  has_many :guest_room_reservations, through: :community
  has_many :common_house_reservations, through: :community

  def admin_users
    AdminUser.where(community_id: community_id)
  end

  def communities
    Community.where(id: community_id)
  end

  def superuser?
    superuser
  end
end
