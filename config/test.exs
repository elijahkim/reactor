use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :reactor, Reactor.Endpoint,
  http: [port: 4001],
  server: false

config :reactor, :random_color_picker, Reactor.RandomColorPickerTest

# Print only warnings and errors during test
config :logger, level: :warn
