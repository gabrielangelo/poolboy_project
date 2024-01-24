import Config

config :poolboylearn, :scraper,
  task_timeout: nil,
  pool_max_concurrency: nil

config :poolboylearn, :http_adapter, timeout: nil

import_config "#{Mix.env()}.exs"
