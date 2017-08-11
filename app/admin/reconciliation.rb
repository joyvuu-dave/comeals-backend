ActiveAdmin.register Reconciliation do
  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false
  config.per_page = 10

  # INDEX
  index do
    column :date
    column :number_of_meals, sortable: false
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
    end
    f.actions
    f.semantic_errors
  end
end
