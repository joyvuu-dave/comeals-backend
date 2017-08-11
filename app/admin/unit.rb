ActiveAdmin.register Unit do
  # STRONG PARAMS
  permit_params :name, :community_id

  # SCOPE
  scope_to :current_admin_user

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
        column 'Residents' do |resident|
          link_to resident.name, admin_resident_path(resident)
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :name
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
    end

    f.actions
    f.semantic_errors
  end
end
