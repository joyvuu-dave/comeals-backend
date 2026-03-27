# == Schema Information
#
# Table name: keys
#
#  id            :bigint           not null, primary key
#  token         :string           not null
#  identity_type :string           not null
#  identity_id   :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Key < ApplicationRecord
  has_secure_token
  belongs_to :identity, polymorphic: true

  before_create :set_token

  def set_token
    self.token = self.class.generate_unique_secure_token
  end
end
