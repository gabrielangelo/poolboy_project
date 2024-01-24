defmodule Adapters.Config.HttpAdapterConfig do
  @moduledoc false
  defp fetch_config_value(config_key, default_value) do
    Application.get_env(:poolboylearn, :http_adapter)[config_key] || default_value
  end

  def max_retries, do: fetch_config_value(:max_retries, 3)
  def backoff_ms, do: fetch_config_value(:backoff_ms, 500)
  def timeout_ms, do: fetch_config_value(:timeout_ms, 10_000)
end
