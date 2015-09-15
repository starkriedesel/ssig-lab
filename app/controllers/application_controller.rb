class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_http_basic
  before_filter :configure_permitted_parameters, if: :devise_controller?
  
  # Set this to true to remove the navbar for a page
  @disable_navbar = false
  
  def after_sign_in_path_for(resource)
    return root_path 
    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')                                            
    if request.referer == sign_in_url                                                                                                                    
      super                                                                                                                                                 
    else                                                                                                                                                    
      stored_location_for(resource) || request.referer || root_path                                                                                         
    end                                                                                                                                                     
  end
  
  def after_sign_out_path_for(resource_or_scope)
    request.referrer
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  private
  def authenticate_http_basic
    return unless Rails.env.production?
    authenticate_or_request_with_http_basic do |username, password|
      username == 'ssig' and password = 'SSIGAdmin1'
    end
  end
    
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :username, :email, :password, :password_confirmation
    end
  end
end
