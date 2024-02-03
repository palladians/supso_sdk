import gleam/fetch
import gleam/uri
import gleam/http/request
import gleam/http.{Post}
import gleam/json.{object, string}

pub type ApiEndpoint {
  LogEvent
  FeatureFlags
}

pub type ClientProps {
  ClientProps(app_url: String, access_token: String)
}

pub type Event {
  Event(project_id: String, channel: String, event: String)
}

pub type Client {
  Client(props: ClientProps)
}

fn event_to_json(event: Event) {
  object([
    #("projectId", string(event.project_id)),
    #("channel", string(event.channel)),
    #("event", string(event.event)),
  ])
  |> json.to_string
}

pub fn get_feature_flags(client: Client, project_id: String) {
  let assert Ok(app_uri) = uri.parse(client.props.app_url)
  let assert Ok(feature_flags_request) = request.from_uri(app_uri)
  let feature_flags_request =
    feature_flags_request
    |> request.set_path("/api/feature_flags/" <> project_id)
    |> request.prepend_header(
      "authorization",
      "Bearer " <> client.props.access_token,
    )
  fetch.send(feature_flags_request)
}

pub fn log_event(client: Client, event: Event) {
  let assert Ok(app_uri) = uri.parse(client.props.app_url)
  let assert Ok(log_event_request) = request.from_uri(app_uri)
  let log_event_request =
    log_event_request
    |> request.set_path("/api/log")
    |> request.set_method(Post)
    |> request.set_body(event_to_json(event))
    |> request.prepend_header(
      "authorization",
      "Bearer " <> client.props.access_token,
    )
  fetch.send(log_event_request)
}

pub fn connect(props: ClientProps) -> Client {
  Client(props)
}
