ActiveAdmin.register Bill do
  # STRONG PARAMS
  permit_params :meal_id, :resident_id, :community_id, :amount, :subdomain

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  filter :meal_reconciliation_id_null, as: :select, collection: [['Yes', false], ['No', true]], include_blank: false, default: false, label: 'Reconciled?'
  config.current_filters = false
  config.sort_order = 'date'

  controller do
    def scoped_collection
      end_of_association_chain.includes(:meal, :resident, resident: :unit)
    end
  end

  # INDEX
  index do
    column Meal.model_name.human, :date, sortable: 'meals.date'
    column :reconciled?
    column :resident, sortable: 'residents.name'
    column :unit, sortable: 'units.name'
    column :amount do |bill|
      number_to_currency(bill.amount) unless bill.amount == 0
    end

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :date
      row :resident
      row :unit
      row :amount do |bill|
        number_to_currency(bill.amount) unless bill.amount == 0
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :meal, label: 'Common Meal Date', collection: Meal.where(community_id: current_admin_user.community_id).order('date DESC').map { |i| [i.date, i.id] }
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
      f.input :resident_id, as: :select, include_blank: false, label: 'Cook', collection: Resident.where(community_id: current_admin_user.community_id).includes(:unit).adult.order('units.name ASC').map { |r| ["#{r.name} - #{r.unit.name}", r.id] }
      f.input :amount, label: '$'
    end

    f.actions
    f.semantic_errors
  end
end
