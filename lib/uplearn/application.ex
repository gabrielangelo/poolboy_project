defmodule Poolboylearn.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      name: {:local, :http_worker},
      worker_module: Adapters.HttpAdapter,
      size: 50,
      max_overflow: 0
    ]
  end

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: HtmlParseSupervisor},
      :poolboy.child_spec(:http_worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: Poolboylearn.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
