class EventsController < ApplicationController
  # GET /events
  def index
    events = list_events
    render json: events.items.map { |event| { id: event.id, summary: event.summary, start_time: event.start.date_time, end_time: event.end.date_time } }
  end

  # GET /events/:id
  def show
    event = google_calendar_service.get_event('primary', params[:id])
    render json: { id: event.id, summary: event.summary, start_time: event.start.date_time, end_time: event.end.date_time }
  end

  # POST /events
  def create
    event = create_event(
      summary: params[:summary],
      # location: params[:location],
      time_zone: params[:time_zone],
      description: params[:description],
      start_time: DateTime.parse(params[:start_time]),
      end_time: DateTime.parse(params[:end_time]),
      attendees: params[:attendees].split(',').map(&:strip) # Assume it's a comma-separated list of emails
    )

    Event.create(
      google_event_id: event.id
    )
    render json: { message: "Event created: #{event.html_link}" }
  end

  # PATCH/PUT /events/:id
  def update
    event = google_calendar_service.get_event('primary', params[:id])
    event.summary = params[:summary]
    event.description = params[:description]
    event.start.date_time = DateTime.parse(params[:start_time])
    event.end.date_time = DateTime.parse(params[:end_time])

    service = google_calendar_service
    service.update_event('primary', event.id, event, send_updates: 'all', conference_data_version: 1)
    render json: { message: "Event updated: #{event.html_link}" }
  end

  # DELETE /events/:id
  def destroy
    service = google_calendar_service
    service.delete_event('primary', params[:id], send_updates: 'all')
    Event.find(params[:id]).destroy
    render json: { message: "Event deleted" }
  end

  private

  def google_calendar_service
    client = authorization
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service
  end

  def list_events
    service = google_calendar_service
    service.list_events('primary', max_results: 3, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)
  end

  def create_event(summary:, description:, start_time:, end_time:, time_zone:, attendees:)
    service = google_calendar_service
    event = Google::Apis::CalendarV3::Event.new(
      summary:,
      # location:,
      description:,
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time, time_zone:),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time, time_zone:),
      attendees: attendees.map { |email| { email: } },
      conference_data: Google::Apis::CalendarV3::ConferenceData.new(
        create_request: Google::Apis::CalendarV3::CreateConferenceRequest.new(
          request_id: SecureRandom.uuid,
          conference_solution_key: Google::Apis::CalendarV3::ConferenceSolutionKey.new(type: 'hangoutsMeet')
        )
      )
    )

    service.insert_event('primary', event, send_updates: 'all', conference_data_version: 1)
  end
end
