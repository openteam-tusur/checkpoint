class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception

  def index
    redirect_to subdivision_path(current_user.subdivisions.first) and return if user_signed_in? && current_user.has_permission?(role: :manager)
    redirect_to lecturer_path(current_user.lecturers.first) and return if user_signed_in? && current_user.has_permission?(role: :lecturer)
  end

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to root_url, :alert => t('cancan.access_denied')
    else
      redirect_to sign_in_url, :alert => t('cancan.access_denied')
    end
  end
end
