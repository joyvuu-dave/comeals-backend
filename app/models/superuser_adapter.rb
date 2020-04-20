class SuperuserAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    return true if action == :read
    return true if action == :create && user.superuser?
    return true if action == :update && user.superuser?
    return true if action == :destroy && user.superuser?
    
    false
  end
end
