# lib/my_supervisor.ex
defmodule HtmlParseSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_html_parser_worker do
    DynamicSupervisor.start_child(__MODULE__, {Adapters.HtmlParser, :ok})
  end

  def stop_html_parser_worker(worker) do
    DynamicSupervisor.terminate_child(__MODULE__, worker)
  end
end
