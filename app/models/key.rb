# == Schema Information
#
# Table name: keys
#
#  id            :bigint           not null, primary key
#  identity_type :string           not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  identity_id   :bigint           not null
#
# Indexes
#
#  index_keys_on_identity_type_and_identity_id  (identity_type,identity_id) UNIQUE
#  index_keys_on_token                          (token) UNIQUE
#

class Key < ApplicationRecord
  has_secure_token
  belongs_to :identity, polymorphic: true

  before_create :set_token

  def set_token
    self.token = self.class.generate_unique_secure_token
  end
end
