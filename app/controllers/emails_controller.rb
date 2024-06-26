class EmailsController < ApplicationController
  # GET /emails
  def index
    emails = list_emails
    render json: emails.messages.map { |email| { id: email.id, snippet: email.snippet } }
  end

  # GET /emails/:id
  def show
    email = google_gmail_service.get_user_message('me', params[:id])
    threads = google_gmail_service.get_user_thread('me', email.thread_id)
    render json: { id: email.id, snippet: email.snippet, thread: threads.messages.map { |message| { id: message.id, snippet: message.snippet, body: message.payload.parts.second&.body } } }
  end

  # POST /emails
  def create
    email = create_email(
      subject: params[:subject],
      body: params[:body],
      to: params[:to]
    )

    Email.create(
      google_email_id: email.id
    )

    render json: { message: "Email sent: #{email.id}" }
  end

  private

  def list_emails
    service = google_gmail_service
    service.list_user_messages('me', max_results: 10)
  end

  def create_email(subject:, body:, to:)
    service = google_gmail_service
    mail = Mail.new
    mail.subject = subject
    mail.to = to
    mail.part content_type: 'multipart/alternative' do |part|
      part.html_part = Mail::Part.new(body:, content_type: 'text/html')
    end

    message = Google::Apis::GmailV1::Message.new(raw: mail.to_s)
    service.send_user_message('me', message)
  end

  def google_gmail_service
    client = authorization
    service = Google::Apis::GmailV1::GmailService.new
    service.authorization = client
    service
  end
end
