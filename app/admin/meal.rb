ActiveAdmin.register Meal do
  # STRONG PARAMS
  permit_params :date, guests_attributes: [:id, :name, :multiplier, :resident_id, :meal_id, :_destroy], resident_ids: []

  # CONFIG
  config.filters = false
  config.per_page = 10
  config.sort_order = 'date_desc'

  # INDEX
  index do
    column :date
    column :number_of_attendees, sortable: false
    column :modified_cost do |meal|
      number_to_currency(meal.modified_cost.to_f / 100) unless meal.modified_cost == 0
    end
    column :unit_cost do |meal|
      number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
    end
    column 'Number of Bills', :bills_count
    column :reconciled, sortable: false

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :date
      row :modified_cost do |meal|
        number_to_currency(meal.modified_cost.to_f / 100) unless meal.modified_cost == 0
      end
      row :unit_cost do |meal|
        number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
      end
      table_for meal.residents.order('name ASC') do
        column 'Residents Attendance' do |resident|
          link_to resident.name, resident
        end
      end
      table_for meal.guests.order('name ASC') do
        column 'Guests in Attendance' do |guest|
          li "#{guest.name} (host: #{guest.resident.name})"
        end
      end
      table_for meal.bills.all do
        column 'Bills' do |bill|
          link_to "#{bill.resident.name} - #{number_to_currency(bill.amount.to_f / 100)}", bill
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :date, as: :datepicker
      f.input :residents, as: :check_boxes, label: 'Attendees', collection: Resident.order('name')
    end
    f.inputs do
      f.has_many :guests, allow_destroy: true, heading: 'Guests', new_record: true do |g|
        g.input :_destroy, as: :hidden
        g.input :name
        g.input :multiplier, label: 'Price Category', as: :select, include_blank: false, collection: [['Adult', 2], ['Child', 1]]
        g.input :resident, label: 'Host', collection: Resident.order('name')
        g.input :meal_id, as: :hidden, input_html: { value: meal.id }
      end
    end

    f.actions
    f.semantic_errors
  end
end
