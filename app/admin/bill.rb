# frozen_string_literal: true

ActiveAdmin.register Bill do
  # STRONG PARAMS
  permit_params :date, :id, :meal_id, :name, :resident_id, :community_id, :amount, :subdomain

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  filter :resident, as: :select, collection: proc { Resident.order(:name).pluck('name', 'id') }, include_blank: true
  filter :meal_reconciliation_id, as: :select, collection: proc {
    Reconciliation.pluck('date', 'id')
  }, include_blank: true
  config.current_filters = false
  config.sort_order = 'meals.date_desc'

  controller do
    before_action { @page_title = 'Cooking Slots' }

    def scoped_collection
      # eager_load (not includes) guarantees LEFT OUTER JOINs, which is required
      # because index columns sort on associated tables: meals.date, residents.name,
      # units.name. includes uses a heuristic to choose between separate queries and
      # JOINs — if it chooses separate queries, ORDER BY on an associated table's
      # column will fail silently or error.
      # preload (not eager_load) for has_many associations to avoid cartesian product
      end_of_association_chain
        .eager_load(:meal, :resident, resident: :unit)
        .preload(meal: %i[meal_residents guests])
    end
  end

  # INDEX
  index do
    column Meal.model_name.human, :date, sortable: 'meals.date'
    column 'Attendees' do |bill|
      bill.meal.meal_residents.size + bill.meal.guests.size
    end
    column '$', :amount do |bill|
      number_to_currency(bill.amount) unless bill.amount.zero?
    end
    column :resident, sortable: 'residents.name'
    column :unit, sortable: 'units.name'

    actions
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :meal, label: 'Common Meal Date', collection: Meal.where(community_id: current_admin_user.community_id).order(date: :desc).map { |i|
        [i.date, i.id]
      }
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
      f.input :resident_id, as: :select, include_blank: false, label: 'Cook', collection: Resident.where(community_id: current_admin_user.community_id).includes(:unit).adult.order('units.name ASC').map { |r|
        ["#{r.name} - #{r.unit.name}", r.id]
      }
      f.input :amount, label: '$'
    end

    f.actions
    f.semantic_errors
  end
end
