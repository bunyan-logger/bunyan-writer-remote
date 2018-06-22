defmodule BunyanWriterRemote.MixProject do
  use Mix.Project

  def project do
    [
      app: :bunyan_writer_remote,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [
      { :bunyan_shared, path: "../bunyan_shared" },
    ]
  end
end
