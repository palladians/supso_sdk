import gleeunit
import gleeunit/should
import supso_sdk
import gleam/fetch
import gleam/string
import gleam/javascript/promise

pub const client_props = supso_sdk.ClientProps(
  app_url: "http://localhost:5173",
  access_token: "45e45ee6-e769-4c6c-9a28-8e4d123339f7",
)

pub fn main() {
  gleeunit.main()
}

pub fn feature_flags_test() {
  client_props
  |> supso_sdk.connect
  |> supso_sdk.get_feature_flags("6827f121-458c-4421-b8d1-edb9d5bd0ee8")
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp) {
    let assert Ok(resp) = resp
    should.be_true(string.length(resp.body) > 0)
    promise.resolve(Ok(Nil))
  })
}

pub fn log_event_test() {
  let event =
    supso_sdk.Event(project_id: "6827f121-458c-4421-b8d1-edb9d5bd0ee8", channel: "test", event: "test")
  client_props
  |> supso_sdk.connect
  |> supso_sdk.log_event(event)
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp) {
    let assert Ok(resp) = resp
    should.be_true(string.length(resp.body) > 0)
    promise.resolve(Ok(Nil))
  })
}
