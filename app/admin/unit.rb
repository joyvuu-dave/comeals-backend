ActiveAdmin.register Unit do
  # STRONG PARAMS
  permit_params :name

  # CONFIG
  config.filters = false
  config.per_page = 10
  config.sort_order = 'name_asc'

  # ACTIONS
  actions :all, except: [:destroy]

  # INDEX
  index do
    column 'Unit', :name
    column :balance do |unit|
      number_to_currency(unit.balance.to_f / 100) unless unit.balance == 0
    end
    column '# of occupants', :number_of_occupants, sortable: false

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :name
      row :balance do |unit|
        number_to_currency(unit.balance.to_f / 100) unless unit.balance == 0
      end
      table_for unit.residents.order('name ASC') do
        column 'Name' do |resident|
          link_to resident.name, resident
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :name
    end

    f.actions
    f.semantic_errors
  end
end
