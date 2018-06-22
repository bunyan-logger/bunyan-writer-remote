defmodule Bunyan.Writer.Remote do

  use Bunyan.Shared.Writable


  def update_configuration(name, new_config) do
    GenServer.call(name, { :update_configuration, new_config })
  end


  # def write_log_message(msg, hosts) do
  #   for host <- hosts do
  #     GenServer.cast(host, { :send, msg })
  #   end
  # end
end
