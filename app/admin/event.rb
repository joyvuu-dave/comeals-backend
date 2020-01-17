ActiveAdmin.register Event do
  # STRONG PARAMS
  permit_params :title, :description, :start_date, :end_date, :allday, :community_id

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false

  # INDEX
  index do
    column :created_at
    column :title
    column :description
    column :start_date
    column :end_date
    column :allday

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :created_at
      row :title
      row :description
      row :start_date
      row :end_date
      row :allday
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :start_date
      f.input :end_date
      f.input :allday
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
    end

    f.actions
    f.semantic_errors
  end
end
