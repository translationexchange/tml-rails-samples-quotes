class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def page
    (params[:page] || 1).to_i
  end
  helper_method :page

  def per_page
    (params[:per_page] || params[:limit] || 50).to_i
  end
  helper_method :per_page

end
