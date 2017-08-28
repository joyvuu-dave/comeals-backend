ActiveAdmin.register Rotation do
  # STRONG PARAMS
  permit_params :meal_ids

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false

  # ACTIONS
  actions :all

  # INDEX
  index do
    column 'Period', :description
    column :meals_count
    column :color

    actions
  end

  # SHOW
  show do
    attributes_table do
      row('Period') { |r| r.description }
      row :meals_count
      row :color
      table_for rotation.meals.order(:date) do
        column 'Meals' do |meal|
          link_to meal.date, admin_meal_path(meal)
        end
      end
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :community_id, input_html: { value: current_admin_user.community_id }, as: :hidden
      f.input :meals, as: :check_boxes, collection: Meal.where(community_id: current_admin_user.community_id).order(:date).map { |m| [m.date.to_s, m.id] }
    end

    f.actions
    f.semantic_errors
  end
end
