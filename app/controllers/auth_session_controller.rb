class AuthSessionController < ApplicationController
  # GET /auth/google
  def google_oauth
    client = google_oauth_client
    auth_uri = client.authorization_uri.to_s
    redirect_to(auth_uri, allow_other_host: true)
  end

  # GET /auth/google/callback
  def google_callback
    client = google_oauth_client
    client.code = params[:code]
    response = client.fetch_access_token!

    UserToken.create(
      google_credentials: response,
      expires_at: Time.now + response['expires_in']
    )

    render json: { message: 'Successfully authenticated with Google' }
  end
end
