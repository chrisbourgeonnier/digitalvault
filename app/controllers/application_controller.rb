class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  # Catch Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
