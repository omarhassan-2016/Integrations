class ApplicationController < ActionController::API
  before_action :authorize_user, except: %i[google_oauth google_callback]

  private

  def authorization
    Signet::OAuth2::Client.new(
      client_id: Rails.application.credentials.dig(:GOOGLE_CLIENT_ID),
      client_secret: Rails.application.credentials.dig(:GOOGLE_CLIENT_SECRET),
      access_token: UserToken.last.google_credentials['access_token']
    )
  end

  def authorize_user
    if UserToken.last.nil? || UserToken.last.token_expired?
      redirect_to '/auth/google'
    end
  end
end
