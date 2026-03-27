ActiveAdmin.register Community do
  # MENU
  menu label: "Community"

  # STRONG PARAMS
  permit_params :name, :cap, :slug

  # CONFIG
  config.filters = false

  # ACTIONS
  actions :all, except: [:destroy, :new]

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  # SCOPE
  scope_to :current_admin_user

  # INDEX
  index do
    column :name
    column :cap do |community|
      number_to_currency(community.cap) if community.capped?
    end
    column :slug

    actions
  end

  # SHOW
  show do
    attributes_table do
      row :id
      row :name
      row :cap do |community|
        number_to_currency(community.cap) if community.capped?
      end
      row :slug
    end
  end

  # FORM
  form do |f|
    f.inputs do
      f.input :name
      f.input :cap, label: 'Cap ($)'
      if f.object.persisted?
        f.input :slug
      end
    end

    f.actions
    f.semantic_errors
  end

end
