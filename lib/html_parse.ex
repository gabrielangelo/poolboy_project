defmodule Adapters.HtmlParser do
  @moduledoc false

  use GenServer

  require Logger

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def parse_html(url, html) do
    Logger.info("parsing #{url}...")

    case HtmlParseSupervisor.start_html_parser_worker() do
      {:ok, pid} ->
        case GenServer.call(pid, {:parse_html, html}) do
          {:ok, result} ->
            Logger.info("body from #{url} parsed!")
            result

          error ->
            error
        end

      _ ->
        {:error, "Failed to start HTML parser worker for #{url}"}
    end
  end

  def handle_call({:parse_html, html}, _from, state) do
    result =
      case parse_html(html) do
        {:ok, data} ->
          {:ok, data}

        {:error, reason} ->
          {:error, reason}
      end

    {:reply, result, state}
  end

  defp parse_html(html) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        {:ok,
         %{}
         |> get_hrefs(document)
         |> get_assets(document)}

      {:error, _} = error ->
        error
    end
  end

  defp get_hrefs(result, document) do
    links =
      Floki.find(document, "a[href]")
      |> Enum.map(&(Floki.attribute(&1, "href") |> List.first()))
      |> Enum.map(&filter_http_url/1)
      |> Enum.filter(&(&1 != ""))

    result
    |> Map.merge(%{links: links})
  end

  defp get_assets(result, document) do
    assets =
      document
      |> Floki.find("img")
      |> Enum.map(&(Floki.attribute(&1, "src") |> List.first()))
      |> Enum.filter(&(&1 != ""))

    result
    |> Map.merge(%{assets: assets})
  end

  defp filter_http_url(url) do
    Regex.scan(~r{https?://\S+}, url)
    |> Enum.join()
  end
end
