ActiveAdmin.register CommonHouseReservation do
  menu label: "Common House"

  # STRONG PARAMS
  permit_params :community_id, :resident_id, :start_date, :end_date, :title

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false

  # FORM
  form do |f|
    f.inputs do
      f.input :resident_id, as: :select, include_blank: false, label: 'Host', collection: Resident.where(community_id: current_admin_user.community_id).includes(:unit).adult.order('units.name ASC').map { |r| ["#{r.name} - #{r.unit.name}", r.id] }
      f.input :title, input_html: { placeholder: "optional" }
      f.input :start_date
      f.input :end_date
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
    end
    f.actions
    f.semantic_errors
  end
end
