defmodule Bunyan.Writer.Remote.State do

  defstruct(
    name:                 Bunyan.Writer.Remote,
    target_process_name:  nil,
    target_nodes:         nil,
    target_process_pid:   nil,
    runtime_log_level:    Bunyan.Shared.Level.of(:warn),
    timer_ref:            nil,
    pending:              [],
    max_pending_size:     100,
    max_pending_wait:     200   # milliseconds
  )

  @valid_options [
    :send_to,            # name of the remote logger process
    :send_to_node,       # the node or nodes when the remote reader lives. If nil, send to all
    :send_to_nodes,      # alias for `send_to_node`
    :runtime_log_level,  # only send >= this,
    :name,               # name of this writer,
  ]

  @required_options [   # oxymoron...
    :send_to,
]

  def from(config) do
    import Bunyan.Shared.Options

    validate_legal_options(config, @valid_options, Bunyan.Writer.Remote)
    validate_required_options(config, @required_options, Bunyan.Writer.Remote)


    %__MODULE__{}
    |> maybe_add(config, :send_to,       :target_process_name)
    |> maybe_add(config, :send_to_node,  :target_nodes)
    |> maybe_add(config, :send_to_nodes, :target_nodes)
    |> maybe_add(config, :name)
    |> maybe_add_level(config, :runtime_log_level)
    |> normalize_node_list()
    # |> check_and_update_send_to()
  end

  defp normalize_node_list(config = %{ target_nodes: nil }) do
    config
  end


  defp normalize_node_list(config = %{ target_nodes: nodes }) when is_list(nodes) do
    Enum.each(nodes, &Node.connect/1)
    :global.sync()
    config
  end

  defp normalize_node_list(config = %{ target_nodes: node }) when is_atom(node) do
    %{ config | target_nodes: [ node ] }
  end

end
