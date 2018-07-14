defmodule Bunyan.Writer.Remote do

  @server __MODULE__.Server

  use Bunyan.Shared.Writable, server_module: @server


  def update_configuration(name \\ @server, new_config) do
    GenServer.call(name, { :update_configuration, new_config })
  end


  # def write_log_message(msg, hosts) do
  #   for host <- hosts do
  #     GenServer.cast(host, { :send, msg })
  #   end
  # end
end
