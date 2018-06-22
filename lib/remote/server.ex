defmodule Bunyan.Writer.Remote.Server do

  use GenServer

  alias Bunyan.Writer.Remote.{ Impl, State }

  def start_link(args) do
    config = Impl.parse_options(args)
    GenServer.start_link(__MODULE__, config, name: config.name)
  end

  def init(config) do
    state = config |> reset_timer()
    IO.inspect init: state
    IO.inspect init: self()
    { :ok, state }
  end


  def handle_cast({ :log_message, msg }, state) do
    IO.inspect log_msg: msg
    state = maybe_send(msg, state)
    { :noreply, state }
  end

  def handle_cast(anything, state) do
    IO.inspect anything: anything
    { :noreply, state }
  end

  defp maybe_send(msg, state = %{ pending: pending }) do
    state = %{ state | pending: [ msg | pending ]}

    cond do
      length(state.pending) >= state.max_pending_size ->
        send_and_reset(state)
      true ->
        state
    end
  end

  defp send_and_reset(state) do
    GenServer.cast(
      state.target_process_pid,
      { :forward_log, Enum.reverse(state.pending) }
    )

    state
    |> reset_timer()
    |> Map.put(:pending, [])
  end

  defp reset_timer(state) do
    if state.timer_ref, do: Process.cancel_timer(state.timer_ref)
    ref = Process.send_after(self(), { :flush }, state.max_pending_wait)
    %{ state | timer_ref: ref }
  end

  def handle_info({ :flush }, state) do
    IO.inspect flush: state
    state = state |> send_and_reset()
    { :noreply, state }
  end
end
