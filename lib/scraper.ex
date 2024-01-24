defmodule Scraper do
  @moduledoc false
  @task_timeout ScraperConfig.task_timeout()
  @pool_max_concurrency ScraperConfig.pool_max_concurrency()

  alias Adapters.Result, as: Result
  require Logger

  def fetch_and_parse(urls) do
    urls
    |> Task.async_stream(&async_fetch_and_parse/1,
      max_concurrency: @pool_max_concurrency,
      ordered: false,
      timeout: @task_timeout
    )
    |> Enum.map(fn {:ok, result} -> result end)
  end

  defp async_fetch_and_parse(url) do
    case Ports.HttpPort.fetch(url) do
      {:ok, html} ->
        %Result{url: url}
        |> Map.merge(Adapters.HtmlParser.parse_html(url, html))

      error ->
        Logger.error(
          "Error occurred while processing the request for URL #{url}: #{inspect(error)}"
        )

        %Result{url: url, errors: [error]}
    end
  end
end
