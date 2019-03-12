defmodule Hidg do
  use GenServer

  def test(device \\ "/dev/hidg0", v \\ 0) do
    {:ok, pid} = Hidg.start_link(device)
    Hidg.output(pid, <<0, v>>)
    pid
  end

  def start_link(fd) do
    GenServer.start_link(__MODULE__, [fd, self()])
  end


  def output(pid, data) do
    GenServer.cast(pid, {:output, data})
  end

  def init([fd, caller]) do
    executable = :code.priv_dir(:hidg) ++ '/ex_hidg'

    port =
      Port.open(
        {:spawn_executable, executable},
        [
          {:args, [fd]},
          {:packet, 2},
          :use_stdio,
          :binary,
          :exit_status
        ]
      )

    state = %{port: port, name: fd, callback: caller}

    {:ok, state}
  end

  def handle_cast({:output, data}, %{port: port} = state) do
    send(port, {self(), {:command, :erlang.term_to_binary({:output, data})}})
    {:noreply, state}
  end

  def handle_info({_, {:exit_status, status}}, state) do
    send(state.callback, {:hidg, state.name, {:exit, status}})
    {:stop, {:exit, status}, state}
  end

  def handle_info({_, {:data, binary}}, state) do
    msg = :erlang.binary_to_term(binary)
    handle_message(msg, state)
  end

  def handle_message({:input, _} = message, state) do
    send(state.callback, {:hidg, state.name, message})
    {:noreply, state}
  end

  def handle_message({:error, reason} = message, state) do
    send(state.callback, {:hidg, state.name, message})
    {:stop, reason, state}
  end

end
