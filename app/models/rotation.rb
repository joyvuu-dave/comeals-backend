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
  validates_presence_of :color

  COLORS = ["#3DC656", "#009EDC", "#D9443F", "#FFC857", "#E9724C"]
  def set_color
    colors = Rotation.pluck(:color).reverse
    prev_colors = [colors[0], colors[1], colors[2], colors[3]]
    self.color = (COLORS - prev_colors)[0]
  end

  def meals_count
    meals.count
  end

end
