class AuditSerializer < ActiveModel::Serializer
  include ApplicationHelper
  attributes :id,
             :user_name,
             :description,
             :display_time

  def user_name
    # Hack for showing who signed up on iPad
    if Rails.env.production?
      return "Common House" if object.user&.id == 60
    end

    if Rails.env.development?
      return "Common House" if object.user&.email == "bowen@email.com"
    end

    resident_name_helper(object.user&.name)
  end

  def description
    parse_audit(object)
  end

  def display_time
    #ActiveSupport::TimeZone.find_tzinfo('Pacific Time (US & Canada)').utc_to_local(object.created_at).strftime("%B %d, %Y at %I:%M %p")
    object.created_at
  end
end
