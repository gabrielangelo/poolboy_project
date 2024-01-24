defmodule Ports.HttpPort do
  @moduledoc false

  @callback fetch(url :: String.t()) :: {:ok, String.t()} | {:error, String.t()}

  def fetch(url), do: implementation().fetch(url)

  defp implementation do
    :poolboylearn
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:implementation)
  end
end
