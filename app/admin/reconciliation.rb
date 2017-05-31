ActiveAdmin.register Reconciliation do
  # CONFIG
  config.filters = false
  config.per_page = 100

  # INDEX
  index do
    column :date
    column :number_of_meals, sortable: false
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :community_id, as: :select, include_blank: false, collection: Community.order('name')
    end
    f.actions
    f.semantic_errors
  end
end
