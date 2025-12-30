# =============================================================================
# Observer Pattern - Generalized/Reusable Template
# =============================================================================
# A reusable PubSub infrastructure that can be applied to ANY use case.
# This file provides two approaches:
#   1. Simple Module-based approach (functional)
#   2. GenServer-based approach (stateful)
#
# Run: elixir generalized_example.exs
# =============================================================================

# =============================================================================
# APPROACH 1: Simple Functional PubSub (using Registry)
# =============================================================================

defmodule SimplePubSub do
  @moduledoc """
  A minimal, reusable PubSub module using Elixir's Registry.
  Copy this module to any project and use it as-is!

  Usage:
    SimplePubSub.start(:my_pubsub)
    SimplePubSub.subscribe(:my_pubsub, "topic_name")
    SimplePubSub.publish(:my_pubsub, "topic_name", any_message)
  """

  @doc "Start a new PubSub registry with a given name"
  def start(name) do
    Registry.start_link(keys: :duplicate, name: name)
  end

  @doc "Subscribe current process to a topic"
  def subscribe(registry, topic) do
    Registry.register(registry, topic, [])
  end

  @doc "Unsubscribe current process from a topic"
  def unsubscribe(registry, topic) do
    Registry.unregister(registry, topic)
  end

  @doc "Publish message to all subscribers of a topic"
  def publish(registry, topic, message) do
    Registry.dispatch(registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {registry, topic, message})
    end)
  end

  @doc "Count subscribers for a topic"
  def count(registry, topic) do
    Registry.lookup(registry, topic) |> length()
  end
end

# =============================================================================
# APPROACH 2: GenServer-based Subject (OOP-like)
# =============================================================================

defmodule Subject do
  @moduledoc """
  A reusable GenServer-based Subject (Observable).
  Use this when you need more control over the notification logic.

  Usage:
    {:ok, subject} = Subject.start_link()
    Subject.attach(subject, self())
    Subject.notify(subject, :any_message)
  """
  use GenServer

  # --- Client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def attach(subject, observer_pid) do
    GenServer.call(subject, {:attach, observer_pid})
  end

  def detach(subject, observer_pid) do
    GenServer.call(subject, {:detach, observer_pid})
  end

  def notify(subject, message) do
    GenServer.cast(subject, {:notify, message})
  end

  def get_observers(subject) do
    GenServer.call(subject, :get_observers)
  end

  # --- Callbacks ---

  @impl true
  def init(_), do: {:ok, []}

  @impl true
  def handle_call({:attach, pid}, _from, observers) do
    if pid in observers do
      {:reply, {:error, :already_attached}, observers}
    else
      {:reply, :ok, [pid | observers]}
    end
  end

  @impl true
  def handle_call({:detach, pid}, _from, observers) do
    {:reply, :ok, List.delete(observers, pid)}
  end

  @impl true
  def handle_call(:get_observers, _from, observers) do
    {:reply, observers, observers}
  end

  @impl true
  def handle_cast({:notify, message}, observers) do
    Enum.each(observers, fn pid ->
      send(pid, {:subject_update, message})
    end)
    {:noreply, observers}
  end
end

# =============================================================================
# APPROACH 3: Behaviour-based Observer (enforces contract)
# =============================================================================

defmodule Observer do
  @moduledoc """
  Behaviour that defines what an Observer must implement.
  Similar to an interface in OOP.
  """

  @callback handle_notification(topic :: atom(), message :: any()) :: :ok
end

defmodule ObserverProcess do
  @moduledoc """
  A generic observer process that delegates to a callback module.

  Usage:
    ObserverProcess.start(MyObserverModule, initial_state)
  """

  def start(callback_module, initial_state \\ %{}) do
    spawn(fn -> loop(callback_module, initial_state) end)
  end

  defp loop(callback_module, state) do
    receive do
      {_registry, topic, message} ->
        callback_module.handle_notification(topic, message)
        loop(callback_module, state)

      {:subject_update, message} ->
        callback_module.handle_notification(:default, message)
        loop(callback_module, state)
    end
  end
end

# =============================================================================
# DEMO: Using the generalized templates
# =============================================================================

IO.puts("""
╔═══════════════════════════════════════════════════════════════════╗
║         GENERALIZED OBSERVER - Reusable Templates                 ║
╚═══════════════════════════════════════════════════════════════════╝
""")

# -----------------------------------------------------------------------------
# Demo 1: Using SimplePubSub
# -----------------------------------------------------------------------------

IO.puts("━━━ Demo 1: SimplePubSub (Registry-based) ━━━\n")

{:ok, _} = SimplePubSub.start(:events)

# Create some observer processes
observer1 = spawn(fn ->
  SimplePubSub.subscribe(:events, :user_events)
  receive do
    {:events, topic, msg} -> IO.puts("   Observer1 got [#{topic}]: #{inspect(msg)}")
  end
end)

observer2 = spawn(fn ->
  SimplePubSub.subscribe(:events, :user_events)
  SimplePubSub.subscribe(:events, :system_events)
  receive do
    {:events, topic, msg} -> IO.puts("   Observer2 got [#{topic}]: #{inspect(msg)}")
  after 500 -> :ok
  end
  receive do
    {:events, topic, msg} -> IO.puts("   Observer2 got [#{topic}]: #{inspect(msg)}")
  after 500 -> :ok
  end
end)

:timer.sleep(50)

SimplePubSub.publish(:events, :user_events, %{action: :login, user: "alice"})
SimplePubSub.publish(:events, :system_events, %{action: :backup_complete})

:timer.sleep(100)

# -----------------------------------------------------------------------------
# Demo 2: Using Subject GenServer
# -----------------------------------------------------------------------------

IO.puts("\n━━━ Demo 2: Subject GenServer (OOP-like) ━━━\n")

{:ok, subject} = Subject.start_link()

# Create observer process
observer3 = spawn(fn ->
  receive do
    {:subject_update, msg} -> IO.puts("   Observer3 got: #{inspect(msg)}")
  end
end)

Subject.attach(subject, observer3)
Subject.notify(subject, {:temperature_changed, 25.5})

:timer.sleep(100)

# -----------------------------------------------------------------------------
# Demo 3: Using Observer Behaviour
# -----------------------------------------------------------------------------

IO.puts("\n━━━ Demo 3: Observer Behaviour (contract-based) ━━━\n")

# Define a concrete observer that implements the behaviour
defmodule LoggingObserver do
  @behaviour Observer

  @impl Observer
  def handle_notification(topic, message) do
    IO.puts("   [LOG] Topic: #{topic}, Message: #{inspect(message)}")
    :ok
  end
end

{:ok, _} = SimplePubSub.start(:logs)

_logger = ObserverProcess.start(LoggingObserver)
|> tap(fn pid ->
  # Need to subscribe from within the process
  send(pid, :dummy)  # Wake it up first
end)

# Manual subscription for demo
spawn(fn ->
  SimplePubSub.subscribe(:logs, :audit)
  receive do
    {_, topic, msg} -> LoggingObserver.handle_notification(topic, msg)
  end
end)

:timer.sleep(50)
SimplePubSub.publish(:logs, :audit, "User deleted record #123")

:timer.sleep(100)

IO.puts("""

═══════════════════════════════════════════════════════════════════
                     TEMPLATE SUMMARY
═══════════════════════════════════════════════════════════════════

┌─────────────────┬────────────────────────────────────────────────┐
│ Approach        │ When to Use                                    │
├─────────────────┼────────────────────────────────────────────────┤
│ SimplePubSub    │ Topic-based messaging, decoupled publishers    │
│ Subject         │ When you need OOP-like attach/detach/notify    │
│ Observer        │ When you want to enforce a contract            │
│ Behaviour       │                                                │
└─────────────────┴────────────────────────────────────────────────┘

HOW TO REUSE:
1. Copy the module you need into your project
2. Optionally rename it (e.g., MyApp.PubSub)
3. Use as shown in the demos above

PRODUCTION ALTERNATIVES:
• Phoenix.PubSub - Distributed pub/sub across nodes
• GenStage - Backpressure-aware producer/consumer
• Registry - Built-in, what SimplePubSub wraps
""")
