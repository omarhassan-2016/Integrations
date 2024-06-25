class UserToken < ApplicationRecord
  def update_google_credentials(credentials)
    self.google_credentials = credentials
    save
  end

  def token_expired?
    expires_at && Time.at(expires_at) < Time.now
  end

  def refresh_access_token!
    client = Signet::OAuth2::Client.new(
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      refresh_token:
    )
    response = client.fetch_access_token!
    update_google_credentials(response)
  end
end
