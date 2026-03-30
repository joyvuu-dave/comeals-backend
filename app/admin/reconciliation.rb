# frozen_string_literal: true

ActiveAdmin.register Reconciliation do
  menu label: 'Recon.'

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false

  permit_params :community_id, :start_date, :end_date

  # INDEX
  index do
    column :date
    column :start_date
    column :end_date
    column :number_of_meals, sortable: false
    actions
  end

  # SHOW
  show do
    attributes_table do
      row :date
      row :start_date
      row :end_date
      row :number_of_meals
    end

    panel 'Settlement Balances' do
      table_for reconciliation.reconciliation_balances
                              .includes(resident: :unit)
                              .joins(resident: :unit)
                              .order('units.name, residents.name') do
        column('Resident') { |rb| link_to rb.resident.name, admin_resident_path(rb.resident) }
        column('Unit') { |rb| rb.resident.unit.name }
        column('Balance') { |rb| number_to_currency(rb.amount) }
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
    end
    f.actions
    f.semantic_errors
  end
end
