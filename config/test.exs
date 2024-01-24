import Config

config :poolboylearn, Ports.HttpPort, implementation: HttpMock

config :logger, :console, format: "$metadata[$level] $message\n"
