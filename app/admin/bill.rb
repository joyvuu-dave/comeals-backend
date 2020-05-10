ActiveAdmin.register Bill do
  # STRONG PARAMS
  permit_params :meal_id, :resident_id, :community_id, :amount, :subdomain

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  filter :resident, as: :select, collection: proc { Resident.order(:name).all.pluck([:name, :id]) }, include_blank: true
  filter :meal_reconciliation_id, as: :select, collection: proc { Reconciliation.all.pluck([:date, :id]) }, include_blank: true
  config.current_filters = false
  config.sort_order = 'date'

  # FIXME: show should link to Comeals
  # Turn off show
  # actions  :index, :edit, :update, :new, :destroy

  controller do
    before_action { @page_title = "Cooking Slots" }

    def scoped_collection
      end_of_association_chain.includes(:meal, :resident, resident: :unit)
    end
  end

  # INDEX
  index do
    column Meal.model_name.human, :date, sortable: 'meals.date'
    column "Attendees", :attendees_count
    column "$", :amount do |bill|
      number_to_currency(bill.amount) unless bill.amount == 0
    end
    column :resident, sortable: 'residents.name'
    column :unit, sortable: 'units.name'

    actions
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
