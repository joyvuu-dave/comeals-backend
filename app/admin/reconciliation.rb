ActiveAdmin.register Reconciliation do
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
    f.actions
    f.semantic_errors
  end
end
