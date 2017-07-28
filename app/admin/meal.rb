ActiveAdmin.register Meal do
  # STRONG PARAMS
  permit_params :date, :subdomain, :community_id, guests_attributes: [:id, :name, :multiplier, :resident_id, :meal_id, :_destroy], resident_ids: []

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false
  config.per_page = 100
  config.sort_order = 'date_desc'

  controller do
    def scoped_collection
      end_of_association_chain.includes(:community, :bills)
    end
  end

  # INDEX
  index do
    column :date
    column :community
    column :attendees_count, sortable: false
    column :max
    column :subsidized?
    column :max_cost do |meal|
      number_to_currency(meal.max_cost.to_f / 100)
    end
    column :balanced?
    column :whats_wrong
    column :modified_cost do |meal|
      number_to_currency(meal.modified_cost.to_f / 100) unless meal.modified_cost == 0
    end
    column :unit_cost do |meal|
      number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
    end
    column 'Number of Bills', :bills_count
    column :reconciled?, sortable: false

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :date
      row :community
      row :max
      row :subsidized?
      row :modified_cost do |meal|
        number_to_currency(meal.modified_cost.to_f / 100) unless meal.modified_cost == 0
      end
      row :unit_cost do |meal|
        number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
      end
      table_for meal.attendees.order('name ASC') do
        column 'Residents Attendance' do |resident|
          link_to resident.name, admin_resident_path(resident)
        end
      end
      table_for meal.guests.order('name ASC') do
        column 'Guests in Attendance' do |guest|
          li "#{guest.name} (host: #{guest.resident.name})"
        end
      end
      table_for meal.bills.all do
        column 'Bills' do |bill|
          link_to "#{bill.resident.name} - #{number_to_currency(bill.amount)}", admin_bill_path(bill)
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :date, as: :datepicker
      f.input :community_id, as: :select, include_blank: false, collection: Community.order('name')
      f.input :max
      f.input :attendees, as: :check_boxes, label: 'Attendees', collection: Resident.where(community_id: 1).includes(:unit).order('units.name ASC').map { |r| ["#{r.name} - #{r.unit.name}", r.id] }
    end
    f.inputs do
      f.has_many :guests, allow_destroy: true, heading: 'Guests', new_record: true do |g|
        g.input :_destroy, as: :hidden
        g.input :name
        g.input :multiplier, label: 'Price Category', as: :select, include_blank: false, collection: [['Adult', 2], ['Child', 1]]
        g.input :resident, label: 'Host', collection: Resident.where(community_id: 1).order('name')
        g.input :meal_id, as: :hidden, input_html: { value: meal.id }
      end
    end

    f.actions
    f.semantic_errors
  end
end
