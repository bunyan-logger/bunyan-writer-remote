defmodule TestRemote.Forward do

  use ExUnit.Case
  alias Bunyan.Writer.Remote.{ Server }
  alias Bunyan.Shared.TestHelpers
  alias TestHelpers.DummyLogger

  import TestHelpers

  setup_all do
    Code.ensure_loaded(DummyLogger)
    DummyLogger.start_link()
    :ok
  end

  test "a message sent to the remote writer appears on the remote logger" do
    { :ok, writer } = Server.start_link(send_to: DummyLogger,
                                        min_log_level: :debug,
                                        name: :remote)

    GenServer.cast(writer, { :log_message, msg("hello") })
    # wait for the queue to flush
    :timer.sleep(300)

    assert [[msg]] = DummyLogger.get_messages
    assert msg.msg == "hello"
  end

  test "messages are queued to be sent until a timeout occurs" do
    { :ok, writer } = Server.start_link(send_to: DummyLogger,
                                        min_log_level: :debug,
                                        name: :remote)

    GenServer.cast(writer, { :log_message, msg("hello") })
    GenServer.cast(writer, { :log_message, msg("goodbye") })

    assert [] = DummyLogger.get_messages
    # wait for the queue to flush
    :timer.sleep(300)

    assert [[msg1, msg2]] = DummyLogger.get_messages
    assert msg1.msg == "hello"
    assert msg2.msg == "goodbye"
  end

end
