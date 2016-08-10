# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :reactor, Reactor.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "f5OcgP2+RUk02PDL6KBmLSDPlFocZajFYJB50MBL5ykw6sYqvUkwfmzJr4XwhIdG",
  render_errors: [view: Reactor.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Reactor.PubSub, adapter: Phoenix.PubSub.PG2]

config :reactor, :random_color_picker, Reactor.RandomColorPicker

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
