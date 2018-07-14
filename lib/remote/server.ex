defmodule Bunyan.Writer.Remote.Server do

  use GenServer

  @moduledoc """

  Write messages to a remote node. THis is identified by a global process name
  (in the `send_to:` parameter. This can be specifie as a simple atom, in which
  case it is assumed the node is already connected to this node, and the atom is
  the process name of the remote reader. `send_to` can also be specified as a
  tuple of `{ process_name, node_name }` in which case we first connect and sync
  with `node_name` before looking up the process.

  We also try to reduce network traffic by buffering outgoing messages. This is
  controlled by configuration parameters:

  * `max_pending_size`

    If the queue of pending messages reaches this number, the queue contents are
    sent.

  * `max_pending_wait`

    No message will remain in the pending queue for more than this number of
    millseconds.


  """

  def start_link(config) do
    { :ok, _pid } = GenServer.start_link(__MODULE__, config, name: config.name)
  end

  def init(config) do
    state = config |> reset_timer()
    { :ok, state }
  end


  def handle_cast({ :log_message, msg }, state) do
    state = maybe_send(msg, state)
    { :noreply, state }
  end

  def handle_cast(anything, state) do
    IO.inspect anything: anything
    { :noreply, state }
  end

  def handle_info({ :flush }, state) do
    state = state |> send_and_reset_timer()
    { :noreply, state }
  end


  defp maybe_send(msg, state = %{ pending: pending }) do
    state = %{ state | pending: [ msg | pending ]}

    cond do
      length(state.pending) >= state.max_pending_size ->
        send_and_reset_timer(state)
      true ->
        state
        |> maybe_start_timer()
    end
  end

  defp send_and_reset_timer(state = %{ pending: [] }) do
    state    # nothing to do, so don't start the timer
  end

  defp send_and_reset_timer(state) do
    state
    |> cast_to_nodes()
    |> reset_timer()
    |> Map.put(:pending, [])
  end


  defp cast_to_nodes(state = %{ target_nodes: nil }) do
    :abcast = GenServer.abcast(
      state.target_process_name,
      { :forward_log, Enum.reverse(state.pending) }
    )
    state
  end

  defp cast_to_nodes(state = %{ target_nodes: nodes }) when is_list(nodes) do
    :abcast = GenServer.abcast(
      nodes,
      state.target_process_name,
      { :forward_log, Enum.reverse(state.pending) }
    )
    state
  end

  defp reset_timer(state) do
    if state.timer_ref, do: Process.cancel_timer(state.timer_ref)
    %{ state | timer_ref: nil }
  end

  defp maybe_start_timer(state = %{ timer_ref: nil }) do
    ref = Process.send_after(self(), { :flush }, state.max_pending_wait)
    %{ state | timer_ref: ref }
  end

  defp maybe_start_timer(state) do
    state
  end



end
