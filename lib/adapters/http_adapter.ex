# lib/http_worker.ex
defmodule Adapters.HttpAdapter do
  @moduledoc false

  use GenServer

  require Logger

  alias Adapters.Config.HttpAdapterConfig

  @timeout_ms HttpAdapterConfig.timeout_ms()
  @behaviour Ports.HttpPort

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl Ports.HttpPort
  def fetch(url) do
    :poolboy.transaction(
      :http_worker,
      fn pid ->
        try do
          Process.sleep(100)
          Logger.info("fetching #{url}...")

          GenServer.call(pid, {:fetch, url})
          |> case do
            {:ok, _} = response ->
              Logger.info("#{url} fetched")
              response

            {:error, reason} ->
              {:error, [errors: [reason], url: url]}
          end
        catch
          e, r ->
            Logger.error("poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}")
            :ok
        end
      end,
      @timeout_ms
    )
  end

  @impl true
  def handle_call({:fetch, url}, _from, state) do
    result =
      case fetch_url(url) do
        {:ok, body} ->
          {:ok, body}

        {:error, reason} ->
          {:error, reason}
      end

    {:reply, result, state}
  end

  defp fetch_url(url) do
    timeout_ms = HttpAdapterConfig.timeout_ms()
    backoff_ms = HttpAdapterConfig.backoff_ms()
    max_retries = HttpAdapterConfig.max_retries()

    with_backoff_and_timeout(url, max_retries, backoff_ms, timeout_ms, fn ->
      case HTTPoison.get(url) do
        {:ok, response} ->
          {:ok, response.body}

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  defp with_backoff_and_timeout(url, max_retries, backoff_ms, timeout_ms, fun) do
    with_backoff_and_timeout(url, max_retries, backoff_ms, timeout_ms, 1, fun)
  end

  defp with_backoff_and_timeout(_, max_retries, _, _, _, _fun) when max_retries <= 0,
    do: {:error, :max_retries_exceeded}

  defp with_backoff_and_timeout(url, max_retries, backoff_ms, timeout_ms, attempt, fun) do
    result =
      try do
        Process.sleep(backoff_ms * (attempt - 1))
        Task.await(Task.async(fun), timeout_ms)
      rescue
        _ -> {:error, :timeout}
      end

    case result do
      {:ok, _} = response ->
        response

      _ ->
        Logger.info("Retrying #{url} (retry ##{max_retries - 1})")

        with_backoff_and_timeout(max_retries - 1, backoff_ms, timeout_ms, attempt + 1, fun)
    end
  end
end
