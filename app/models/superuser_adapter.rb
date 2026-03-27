class SuperuserAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    return true if action == :read
    return true if [:create, :new].include?(action) && user.superuser?
    return true if [:update, :edit].include?(action) && user.superuser?
    return true if action == :destroy && user.superuser?

    false
  end
end
