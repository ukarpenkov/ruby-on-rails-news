# frozen_string_literal: true

app_id = ENV["FACEBOOK_APP_ID"].presence || Rails.application.credentials.dig(:facebook, :app_id).presence
app_secret = ENV["FACEBOOK_APP_SECRET"].presence || Rails.application.credentials.dig(:facebook, :app_secret).presence

Rails.application.config.x.facebook_login = app_id.present? && app_secret.present?

if Rails.application.config.x.facebook_login
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, app_id, app_secret,
             scope: "public_profile",
             info_fields: "name"
  end
end

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true
