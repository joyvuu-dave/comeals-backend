ActiveAdmin.register Resident do
  # STRONG PARAMS
  permit_params :name, :multiplier, :unit_id

  # CONFIG
  config.filters = false
  config.per_page = 10
  config.sort_order = 'name_asc'

  # ACTIONS
  actions :all, except: [:destroy]

  # INDEX
  index do
    column :name
    column 'Price Category', :multiplier, sortable: :multiplier do |resident|
      if resident.multiplier == 2
        'Adult'
      elsif resident.multiplier == 1
        'Child'
      else
        # Note: this would only be used if we allowed custom multiplier input
        "Adult x #{number_with_precision((resident.multiplier.to_f / 2), precision: 1, strip_insignificant_zeros: true)}"
      end
    end
    column :unit
    column 'Balance', :balance do |resident|
      number_to_currency(resident.balance.to_f / 100) unless resident.balance == 0
    end

    actions
  end

  # SHOW
  show do
    attributes_table do
      table_for resident.meals.order('date') do
        column 'Meals Attended' do |meal|
          link_to meal.date, meal
        end
        column 'Unit Cost' do |meal|
          number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
        end
      end
      table_for resident.bills.all do
        column 'Bills' do |bill|
          link_to bill.meal.date, bill
        end
        column 'Amount' do |bill|
          number_to_currency(bill.amount.to_f / 100) unless bill.amount == 0
        end
      end
      table_for resident.guests.all do
        column 'Guest Name' do |guest|
          li guest.name
        end
        column 'Price Category', :multiplier do |guest|
          if guest.multiplier == 2
            'Adult'
          elsif guest.multiplier == 1
            'Child'
          else
            # Note: this would only be used if we allowed custom multiplier input
            "Adult x #{number_with_precision((guest.multiplier.to_f / 2), precision: 1, strip_insignificant_zeros: true)}"
          end
        end
        column 'Meal Date' do |guest|
          link_to guest.meal.date, guest.meal
        end
        column 'Unit Cost' do |guest|
          number_to_currency(guest.meal.unit_cost.to_f / 100) unless guest.meal.unit_cost == 0
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :name
      f.input :multiplier, label: 'Price Category', as: :radio, collection: [['Adult', 2], ['Child', 1]]
      f.input :unit, collection: Unit.order('name')
    end
    f.actions
    f.semantic_errors
  end
end
