# == Schema Information
#
# Table name: communities
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  cap             :integer
#  rotation_length :integer
#  slug            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

class Community < ApplicationRecord
  include FriendlyId
  friendly_id :name, :use => :slugged
  validates :name, uniqueness: { case_sensitive: false }

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

end
