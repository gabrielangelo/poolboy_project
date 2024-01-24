defmodule ScraperConfig do
  @moduledoc false
  defp fetch_config_value(config_key, default_value) do
    Application.get_env(:poolboylearn, :scraper)[config_key] || default_value
  end

  def retry_interval, do: fetch_config_value(:retry_interval, 500)
  def max_retries, do: fetch_config_value(:max_retries, 3)
  def task_timeout, do: fetch_config_value(:task_timeout, 30_000)
  def pool_max_concurrency, do: fetch_config_value(:pool_max_concurrency, 10)
end
