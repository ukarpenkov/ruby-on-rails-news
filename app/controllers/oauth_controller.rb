# frozen_string_literal: true

class OauthController < ApplicationController
  def facebook
    auth = request.env["omniauth.auth"]
    return reject_facebook if auth.blank?

    user = User.from_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_path, status: :see_other
  end

  def failure
    reject_facebook
  end

  def facebook_unavailable
    redirect_to login_path, alert: "Вход через Facebook ещё не настроен", status: :see_other
  end

  private

  def reject_facebook
    redirect_to login_path, alert: "Не удалось войти через Facebook", status: :see_other
  end
end
