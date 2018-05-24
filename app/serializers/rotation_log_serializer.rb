class RotationLogSerializer < ActiveModel::Serializer
  attributes :id,
             :description

  has_many :residents

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :display_name,
               :signed_up

    def display_name
      "#{object.unit.name} - #{object.name}"
    end

    def signed_up
      instance_options[:cook_ids].include?(object.id)
    end
  end

end
