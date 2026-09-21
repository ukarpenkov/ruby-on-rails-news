class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :favorited?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    redirect_to login_path, status: :see_other unless current_user
  end

  def favorited?(article)
    return false unless current_user

    favorite_article_ids.include?(article.id)
  end

  def favorite_article_ids
    @favorite_article_ids ||= current_user.favorite_article_ids
  end
end
