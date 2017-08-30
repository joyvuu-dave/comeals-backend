# == Schema Information
#
# Table name: rotations
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  description  :string           not null
#  color        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_rotations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class Rotation < ApplicationRecord
  belongs_to :community
  has_many :meals, dependent: :nullify

  before_validation :set_color, on: :create
  after_commit :set_description
  validates_presence_of :color

  COLORS = ["#3DC656", "#009EDC", "#D9443F", "#FFC857", "#E9724C"]
  def set_color
    colors = Rotation.where(community_id: community_id).pluck(:color).reverse
    prev_colors = []
    prev_colors.push([colors[0]) unless colors[0].nil?
    prev_colors.push([colors[1]) unless colors[1].nil?
    prev_colors.push([colors[2]) unless colors[2].nil?
    prev_colors.push([colors[3]) unless colors[3].nil?

    self.color = (COLORS - prev_colors)[0]
  end

  def set_description
    self.update_columns(description: "#{self.meals&.order(:date)&.first&.date&.to_s} to #{self.meals&.order(:date)&.last&.date&.to_s}")
  end

  def meals_count
    meals.count
  end

end
