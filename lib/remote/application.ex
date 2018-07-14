defmodule Bunyan.Writer.Remote.Application do

  use Application

  def start(_type, _args) do
    children = [
      { Bunyan.Writer.Remote, [] },
    ]

    opts = [strategy: :one_for_one, name: Bunyan.Writer.Remote.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
