class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    redirect_to subdivision_path(current_user.subdivisions.first) and return if current_user && current_user.manager?
    redirect_to lecturer_path(current_user.lecturers.first) and return if current_user && current_user.lecturer?
  end

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to root_url, :alert => t('cancan.access_denied')
    else
      redirect_to new_user_session_url, :alert => t('cancan.access_denied')
    end
  end
end
