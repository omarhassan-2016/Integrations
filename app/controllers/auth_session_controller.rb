class AuthSessionController < ApplicationController
  # GET /auth/google
  def google_oauth
    client = google_oauth_client
    auth_uri = client.authorization_uri.to_s
    redirect_to(auth_uri, allow_other_host: true)
  end

  # GET /auth/zoom
  def zoom_oauth
    zoom_auth_url = "https://zoom.us/oauth/authorize?response_type=code&client_id=#{Rails.application.credentials.dig(:ZOOM_CLIENT_ID)}&redirect_uri=#{Rails.application.credentials.dig(:ZOOM_REDIRECT_URI)}"
    redirect_to(zoom_auth_url, allow_other_host: true)
  end

  # GET /auth/zoom/callback
  def zoom_callback
    if params[:code]
      uri = URI.parse("https://zoom.us/oauth/token")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(Rails.application.credentials.dig(:ZOOM_CLIENT_ID), Rails.application.credentials.dig(:ZOOM_CLIENT_SECRET))
      request.set_form_data(
        "grant_type" => "authorization_code",
        "code" => params[:code],
        "redirect_uri" => Rails.application.credentials.dig(:ZOOM_REDIRECT_URI)
      )

      req_options = {
        use_ssl: uri.scheme == "https"
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == "200"
        result = JSON.parse(response.body)
        access_token = result["access_token"]
        refresh_token = result["refresh_token"]
        render json: { access_token: access_token, refresh_token: refresh_token }
      else
        render json: { error: response.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "Authorization code not provided" }, status: :unprocessable_entity
    end
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
