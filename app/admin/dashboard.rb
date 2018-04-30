ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: 'Meal Reconciliation' do

    # Here is an example of a simple dashboard with columns and panels.
    columns do
      column do
        panel "Units - #{current_admin_user.units.count(true)}" do
          ul do
            current_admin_user.units.order('name').map do |unit|
              li link_to(unit.name, admin_unit_path(unit))
            end
          end
        end
      end

      column do
        panel "Residents - #{current_admin_user.residents.count(true)}" do
          ul do
            current_admin_user.residents.order('name').map do |resident|
              li link_to(resident.name, admin_resident_path(resident))
            end
          end
        end
      end

      column do
        panel "Unreconciled Meals - #{current_admin_user.meals.unreconciled.count(true)}" do
          ul do
            current_admin_user.meals.unreconciled.order('date DESC').map do |meal|
              li link_to(meal.date, admin_meal_path(meal))
            end
          end
        end
      end

      column do
        panel 'Averages' do
          ul do
            li "Cost per adult: #{current_admin_user.community.unreconciled_ave_cost}"
            li "Attendees per meal: #{current_admin_user.community.unreconciled_ave_number_of_attendees}"
          end
        end
      end
    end
  end
end
