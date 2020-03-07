ActiveAdmin.register Rotation do
  # STRONG PARAMS
  permit_params :description, :community_id, meal_ids: []

  # SCOPE
  scope_to :current_admin_user

  # CONFIG
  config.filters = false

  # ACTIONS
  actions :all

  # INDEX
  index do
    column :id
    column :place_value
    column :start_date
    column 'Period', :description
    column :meals_count
    column :color

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :id
      row :place_value
      row :start_date
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
      f.input :description, input_html: { value: "" }, as: :hidden
      f.input :meals, as: :check_boxes, collection: Meal.where(rotation_id: nil, community_id: current_admin_user.community_id).order(:date).map { |m| [m.date.to_s, m.id] }
    end

    f.actions
    f.semantic_errors
  end
end
