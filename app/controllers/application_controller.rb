class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  if Rails.env.development?
    skip_before_action :verify_authenticity_token
  end
  include UserSign

  around_action :set_thread_current_variable
  
  private
  def set_thread_current_variable
    Current.request = request
    yield
  ensure
    Current.request = nil
  end

end
