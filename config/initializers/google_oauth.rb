require 'google/apis/calendar_v3'
require 'signet/oauth_2/client'

def google_oauth_client
  Signet::OAuth2::Client.new(
    client_id: Rails.application.credentials.dig(:GOOGLE_CLIENT_ID),
    client_secret: Rails.application.credentials.dig(:GOOGLE_CLIENT_SECRET),
    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
    token_credential_uri: 'https://oauth2.googleapis.com/token',
    scope: Rails.application.credentials.dig(:GOOGLE_AUTH_SCOPE),
    redirect_uri: Rails.application.credentials.dig(:GOOGLE_REDIRECT_URI)
  )
end
