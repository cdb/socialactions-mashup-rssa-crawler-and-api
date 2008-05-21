# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1a6bbb367383c24380852761da6c194f'
  
  def search_params
    params[:sites] = params[:sites].split(',') if (params[:sites].is_a? String)
    params.slice(:keywords, :action_type, :created, :sites, :kind, :ip_address).delete_if{|k,v| v.nil? || v.empty?}
  end
  helper_method :search_params
  
  def search_params_readable
    params = search_params
    params[:sites] = params[:sites].join(',') if (params[:sites] and params[:sites].is_a? Hash)
    params
  end
  helper_method :search_params_readable
end
