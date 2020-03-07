# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint           not null, primary key
#  color              :string           not null
#  description        :string           default(""), not null
#  place_value        :integer
#  residents_notified :boolean          default("false"), not null
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  community_id       :bigint           not null
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
  attr_accessor :no_email

  belongs_to :community
  has_many :meals, dependent: :nullify
  has_many :bills, through: :meals
  has_many :cooks, -> { distinct }, through: :bills, source: :resident
  has_many :residents, -> { where(active: true, can_cook: true).where("multiplier >= ?", 2) }, through: :community

  before_validation :set_color, on: :create
  after_save :set_description
  after_save :set_start_date
  after_commit :set_place_value
  after_create_commit :notify_residents
  validates_presence_of :color

  accepts_nested_attributes_for :meals

  COLORS = ["#3DC656", "#009EDC", "#D9443F", "#FFC857", "#E9724C"]
  def set_color
    used_colors = Rotation.where(community_id: community_id).pluck(:color).reverse
    prev_colors = []
    prev_colors.push(used_colors[0]) unless used_colors[0].nil?
    prev_colors.push(used_colors[1]) unless used_colors[1].nil?
    prev_colors.push(used_colors[2]) unless used_colors[2].nil?
    prev_colors.push(used_colors[3]) unless used_colors[3].nil?

    self.color = (COLORS - prev_colors)[0]
  end

  def set_description
    self.update_columns(description: "#{self.meals&.order(:date)&.first&.date&.to_s} to #{self.meals&.order(:date)&.last&.date&.to_s}")
  end

  def set_start_date
    self.update_columns(start_date: self.meals&.order(:date)&.first&.date)
  end

  def meals_count
    meals.count
  end

  def set_place_value
    Rotation.order('start_date ASC').pluck(:id).each_with_index do |id, index|
      Rotation.find(id).update_columns(place_value: index + 1)
    end
  end

  def notify_residents
    return if no_email

    residents = community.residents.where(active: true).where.not(email: nil)
    residents.each do |resident|
      ResidentMailer.new_rotation_email(resident, self, community).deliver_now
    end
  end


end
