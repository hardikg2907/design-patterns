# =============================================================================
# Observer Pattern - Basic Example
# =============================================================================
# A simple YouTube-like notification system where subscribers get notified
# when a channel uploads a new video.
#
# Run this file: elixir basic_example.exs
# =============================================================================

defmodule YouTubeChannel do
  @moduledoc """
  The Subject/Publisher - A YouTube channel that notifies subscribers
  when new videos are uploaded.

  In OOP, this would be a class that maintains a list of observers.
  In Elixir, we use a GenServer (stateful process) to manage subscribers.
  """

  use GenServer

  # ──────────────────────────────────────────────────────────────────────────
  # Client API (how other processes interact with the channel)
  # ──────────────────────────────────────────────────────────────────────────

  @doc "Start a new channel with a given name"
  def start_link(channel_name) do
    GenServer.start_link(__MODULE__, channel_name, name: via_tuple(channel_name))
  end

  @doc "Subscribe to a channel - the caller process will receive notifications"
  def subscribe(channel_name) do
    GenServer.call(via_tuple(channel_name), {:subscribe, self()})
  end

  @doc "Unsubscribe from a channel"
  def unsubscribe(channel_name) do
    GenServer.call(via_tuple(channel_name), {:unsubscribe, self()})
  end

  @doc "Upload a new video - this notifies all subscribers!"
  def upload_video(channel_name, video_title) do
    GenServer.cast(via_tuple(channel_name), {:upload, video_title})
  end

  @doc "Get list of current subscribers (for debugging)"
  def get_subscribers(channel_name) do
    GenServer.call(via_tuple(channel_name), :get_subscribers)
  end

  # Helper to create a unique name for each channel
  defp via_tuple(channel_name) do
    {:global, {:youtube_channel, channel_name}}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Server Callbacks (internal implementation)
  # ──────────────────────────────────────────────────────────────────────────

  @impl true
  def init(channel_name) do
    IO.puts("\n📺 Channel '#{channel_name}' is now live!")
    # State: {channel_name, list_of_subscriber_pids}
    {:ok, {channel_name, []}}
  end

  @impl true
  def handle_call({:subscribe, subscriber_pid}, _from, {name, subscribers}) do
    if subscriber_pid in subscribers do
      {:reply, {:error, :already_subscribed}, {name, subscribers}}
    else
      IO.puts("✅ New subscriber joined '#{name}'")
      {:reply, :ok, {name, [subscriber_pid | subscribers]}}
    end
  end

  @impl true
  def handle_call({:unsubscribe, subscriber_pid}, _from, {name, subscribers}) do
    new_subscribers = List.delete(subscribers, subscriber_pid)
    IO.puts("👋 Subscriber left '#{name}'")
    {:reply, :ok, {name, new_subscribers}}
  end

  @impl true
  def handle_call(:get_subscribers, _from, {name, subscribers} = state) do
    {:reply, {name, length(subscribers)}, state}
  end

  @impl true
  def handle_cast({:upload, video_title}, {name, subscribers}) do
    IO.puts("\n🎬 '#{name}' uploaded: \"#{video_title}\"")
    IO.puts("📢 Notifying #{length(subscribers)} subscriber(s)...\n")

    # This is the "notify" part - send message to ALL observers
    Enum.each(subscribers, fn pid ->
      send(pid, {:new_video, name, video_title})
    end)

    {:noreply, {name, subscribers}}
  end
end

# =============================================================================
# Subscriber Process (Observer)
# =============================================================================

defmodule Subscriber do
  @moduledoc """
  The Observer - A subscriber that receives notifications from channels.

  This is a simple process that listens for video notifications.
  In a real app, this could be a GenServer with more complex logic.
  """

  @doc "Start a new subscriber process with a name"
  def start(name) do
    spawn(fn -> loop(name) end)
  end

  defp loop(name) do
    receive do
      {:new_video, channel, video_title} ->
        IO.puts("   🔔 #{name} received: New video '#{video_title}' from #{channel}")
        loop(name)

      :stop ->
        IO.puts("   👋 #{name} stopped")
    end
  end
end

# =============================================================================
# Demo: Let's see it in action!
# =============================================================================

IO.puts("""
╔═══════════════════════════════════════════════════════════════════╗
║         OBSERVER PATTERN - YouTube Notification System            ║
╚═══════════════════════════════════════════════════════════════════╝
""")

# Step 1: Create a YouTube channel (the Subject)
{:ok, _pid} = YouTubeChannel.start_link("ElixirLearning")

# Step 2: Create some subscribers (the Observers)
alice = Subscriber.start("Alice")
bob = Subscriber.start("Bob")
charlie = Subscriber.start("Charlie")

# Step 3: Subscribe them to the channel
# Note: We can't call subscribe from within the subscriber process,
# so we manually register them
GenServer.call({:global, {:youtube_channel, "ElixirLearning"}}, {:subscribe, alice})
GenServer.call({:global, {:youtube_channel, "ElixirLearning"}}, {:subscribe, bob})
GenServer.call({:global, {:youtube_channel, "ElixirLearning"}}, {:subscribe, charlie})

# Give a moment for output to display
:timer.sleep(100)

# Step 4: Upload a video - ALL subscribers get notified!
YouTubeChannel.upload_video("ElixirLearning", "Observer Pattern in Elixir")

# Wait for notifications to be processed
:timer.sleep(200)

# Step 5: Bob unsubscribes
GenServer.call({:global, {:youtube_channel, "ElixirLearning"}}, {:unsubscribe, bob})

:timer.sleep(100)

# Step 6: Upload another video - only Alice and Charlie get notified
YouTubeChannel.upload_video("ElixirLearning", "GenServer Deep Dive")

:timer.sleep(200)

# Check subscriber count
{name, count} = YouTubeChannel.get_subscribers("ElixirLearning")
IO.puts("\n📊 '#{name}' now has #{count} subscriber(s)")

IO.puts("""

═══════════════════════════════════════════════════════════════════
                           KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

1. SUBJECT (YouTubeChannel):
   - Maintains list of observers (subscriber PIDs)
   - Has subscribe/unsubscribe functions (attach/detach)
   - Notifies all observers when state changes (upload_video)

2. OBSERVER (Subscriber):
   - Receives notifications via message passing
   - Uses pattern matching to handle {:new_video, ...} messages
   - Each observer handles the notification independently

3. ELIXIR ADVANTAGES:
   - No shared mutable state (each process has its own state)
   - Message passing is natural for notifications
   - Processes are lightweight (can have millions of subscribers)
   - Automatic cleanup when processes die
""")
