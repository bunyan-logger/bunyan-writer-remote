defmodule TestRemoteOptions do

  use ExUnit.Case
  alias Bunyan.Writer.Remote.{ Impl }
  alias Bunyan.Shared.{ Level, TestHelpers.DummyLogger }



  setup_all do
    DummyLogger.start_link()
    :ok
  end

  test "send_to option is required" do
    assert_raise(RuntimeError,
                 ~r/send_to.+option is required/,
                 fn ->  Impl.parse_options([]) end)
  end

  test "the send_to option is extracted" do
    state = Impl.parse_options(send_to: DummyLogger)
    assert state.target_process_name == DummyLogger
    assert state.target_process_pid  == Process.whereis(DummyLogger)
  end

  test "exception is raised if the send_to process doesn't exist" do
    assert_raise(RuntimeError,
                 ~r/Cannot find a remote logger named BadLogger/,
                 fn -> Impl.parse_options(send_to: BadLogger) end)
  end

  test "the minimum log level is set" do
    state = Impl.parse_options(send_to: DummyLogger)
    assert state.min_log_level == Level.of(:warn)
    state = Impl.parse_options(send_to: DummyLogger, min_log_level: :info)
    assert state.min_log_level == Level.of(:info)
  end

end
