ActiveAdmin.register Resident do
  # STRONG PARAMS
  permit_params :name, :multiplier, :unit_id, :community_id, :email, :password, :vegetarian

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false
  config.sort_order = 'name_asc'

  # ACTIONS
  actions :all, except: [:destroy]

  controller do
    def scoped_collection
      end_of_association_chain.includes(
        { :bills => :meal },
        { :bills => :resident },
        { :bills => :community },
        { :unit => :residents },
        { :meal_residents => :meal },
        { :meal_residents => :resident },
        { :meal_residents => :community },
        { :meals => :reconciliation },
        { :meals => :community },
        { :meals => :bills },
        { :meals => :meal_residents },
        { :meals => :guests },
        { :meals => :residents },
        { :guests => :meal },
        { :guests => :resident },
        { :community => :bills },
        { :community => :meals },
        { :community => :meal_residents },
        { :community => :reconciliations },
        { :community => :residents },
        { :community => :guests },
        { :community => :units }
      )
    end
  end

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
    column :can_cook
    column 'Balance', :balance do |resident|
      number_to_currency(resident.balance.to_f / 100) unless resident.balance == 0
    end

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :id
      row :name
      row :unit
      row :can_cook
      row :email
      row :vegetarian
      table_for resident.meals.order('date') do
        column 'Meals Attended' do |meal|
          link_to meal.date, admin_meal_path(meal)
        end
        column 'Unit Cost' do |meal|
          number_to_currency(meal.unit_cost.to_f / 100) unless meal.unit_cost == 0
        end
      end
      table_for resident.bills.all do
        column 'Bills' do |bill|
          link_to bill.meal.date, admin_bill_path(bill)
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
          link_to guest.meal.date, admin_meal_path(guest.meal)
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
      f.input :email
      if f.object.new_record?
        f.input :password
      end
      f.input :vegetarian
      f.input :multiplier, label: 'Price Category', as: :radio, collection: [['Adult', 2], ['Child', 1]]
      f.input :unit, collection: Unit.where(community_id: current_admin_user.community_id).order('name')
      f.input :can_cook
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
    end
    f.label 'Note: passwords can be reset through the resident login page'
    f.actions
    f.semantic_errors
  end
end
