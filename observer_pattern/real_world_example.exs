# =============================================================================
# Observer Pattern - Real World Example: Stock Price Ticker
# =============================================================================
# A stock trading system where:
# - Stock prices are published in real-time
# - Different types of observers react differently:
#   - Display boards show prices
#   - Alert systems check thresholds
#   - Loggers record all changes
#
# Run: elixir real_world_example.exs
# =============================================================================

defmodule StockExchange do
  @moduledoc """
  The Subject - Maintains stock prices and notifies all observers.
  Uses GenServer to manage state and handle concurrent updates.
  """
  use GenServer

  # ─────────────────────────────────────────────────────────────────
  # Client API
  # ─────────────────────────────────────────────────────────────────

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(observer_pid, stocks \\ :all) do
    GenServer.call(__MODULE__, {:subscribe, observer_pid, stocks})
  end

  def unsubscribe(observer_pid) do
    GenServer.call(__MODULE__, {:unsubscribe, observer_pid})
  end

  def update_price(symbol, price) do
    GenServer.cast(__MODULE__, {:update_price, symbol, price})
  end

  def get_price(symbol) do
    GenServer.call(__MODULE__, {:get_price, symbol})
  end

  # ─────────────────────────────────────────────────────────────────
  # Server Callbacks
  # ─────────────────────────────────────────────────────────────────

  @impl true
  def init(_) do
    state = %{
      prices: %{},           # %{symbol => price}
      observers: []          # [{pid, filter}] where filter is :all or [symbols]
    }
    {:ok, state}
  end

  @impl true
  def handle_call({:subscribe, pid, filter}, _from, state) do
    observers = [{pid, filter} | state.observers]
    {:reply, :ok, %{state | observers: observers}}
  end

  @impl true
  def handle_call({:unsubscribe, pid}, _from, state) do
    observers = Enum.reject(state.observers, fn {p, _} -> p == pid end)
    {:reply, :ok, %{state | observers: observers}}
  end

  @impl true
  def handle_call({:get_price, symbol}, _from, state) do
    {:reply, Map.get(state.prices, symbol), state}
  end

  @impl true
  def handle_cast({:update_price, symbol, new_price}, state) do
    old_price = Map.get(state.prices, symbol)
    new_prices = Map.put(state.prices, symbol, new_price)

    # Notify all interested observers
    notify_observers(state.observers, symbol, old_price, new_price)

    {:noreply, %{state | prices: new_prices}}
  end

  defp notify_observers(observers, symbol, old_price, new_price) do
    Enum.each(observers, fn {pid, filter} ->
      should_notify = filter == :all or symbol in filter

      if should_notify do
        send(pid, {:stock_update, symbol, old_price, new_price, DateTime.utc_now()})
      end
    end)
  end
end

# =============================================================================
# Different Types of Observers
# =============================================================================

defmodule DisplayBoard do
  @moduledoc "Observer that displays stock prices on a 'board'"

  def start(name) do
    spawn(fn -> loop(name, %{}) end)
  end

  defp loop(name, prices) do
    receive do
      {:stock_update, symbol, _old, new_price, _time} ->
        updated = Map.put(prices, symbol, new_price)
        display(name, updated)
        loop(name, updated)
    end
  end

  defp display(name, prices) do
    price_str = prices |> Enum.map(fn {s, p} -> "#{s}: ₹#{p}" end) |> Enum.join(" | ")
    IO.puts("📺 [#{name}] #{price_str}")
  end
end

defmodule PriceAlertSystem do
  @moduledoc "Observer that triggers alerts when price crosses thresholds"

  def start(thresholds) do
    # thresholds: %{"RELIANCE" => {high: 2500, low: 2300}, ...}
    spawn(fn -> loop(thresholds) end)
  end

  defp loop(thresholds) do
    receive do
      {:stock_update, symbol, old_price, new_price, _time} ->
        check_thresholds(symbol, old_price, new_price, thresholds)
        loop(thresholds)
    end
  end

  defp check_thresholds(symbol, old_price, new_price, thresholds) do
    case Map.get(thresholds, symbol) do
      nil -> :ok

      %{high: high, low: low} ->
        cond do
          old_price && old_price < high && new_price >= high ->
            IO.puts("🚨 ALERT: #{symbol} crossed HIGH threshold! ₹#{new_price} >= ₹#{high}")

          old_price && old_price > low && new_price <= low ->
            IO.puts("🚨 ALERT: #{symbol} fell below LOW threshold! ₹#{new_price} <= ₹#{low}")

          true -> :ok
        end
    end
  end
end

defmodule TradeLogger do
  @moduledoc "Observer that logs all price changes for audit"

  def start(log_file) do
    spawn(fn ->
      IO.puts("📝 Logger started, writing to: #{log_file}")
      loop(log_file)
    end)
  end

  defp loop(log_file) do
    receive do
      {:stock_update, symbol, old_price, new_price, timestamp} ->
        change = calculate_change(old_price, new_price)
        time_str = Calendar.strftime(timestamp, "%H:%M:%S")
        log_entry = "[#{time_str}] #{symbol}: ₹#{old_price || "N/A"} -> ₹#{new_price} (#{change})"

        IO.puts("   📝 #{log_entry}")
        # In real app: File.write!(log_file, log_entry <> "\n", [:append])

        loop(log_file)
    end
  end

  defp calculate_change(nil, _new), do: "NEW"
  defp calculate_change(old, new) when new > old, do: "+#{Float.round((new - old) / old * 100, 2)}%"
  defp calculate_change(old, new) when new < old, do: "#{Float.round((new - old) / old * 100, 2)}%"
  defp calculate_change(_, _), do: "0%"
end

# =============================================================================
# Demo: Stock Trading Simulation
# =============================================================================

IO.puts("""
╔═══════════════════════════════════════════════════════════════════╗
║         REAL WORLD EXAMPLE - Stock Price Ticker System            ║
╚═══════════════════════════════════════════════════════════════════╝
""")

# Start the stock exchange
{:ok, _} = StockExchange.start_link()

# Create different types of observers
display = DisplayBoard.start("Main Board")
alert_system = PriceAlertSystem.start(%{
  "RELIANCE" => %{high: 2500, low: 2300},
  "TCS" => %{high: 3800, low: 3500}
})
logger = TradeLogger.start("trades.log")

# Subscribe them with different filters
StockExchange.subscribe(display, ["RELIANCE", "TCS", "INFY"])
StockExchange.subscribe(alert_system, ["RELIANCE", "TCS"])
StockExchange.subscribe(logger, :all)  # Logger wants everything

:timer.sleep(100)
IO.puts("\n━━━ Market Opening ━━━\n")

# Simulate initial prices
StockExchange.update_price("RELIANCE", 2400)
:timer.sleep(80)
StockExchange.update_price("TCS", 3700)
:timer.sleep(80)
StockExchange.update_price("INFY", 1500)
:timer.sleep(80)
StockExchange.update_price("HDFC", 2800)
:timer.sleep(100)

IO.puts("\n━━━ Price Movements ━━━\n")

# Price goes up!
StockExchange.update_price("RELIANCE", 2480)
:timer.sleep(80)
StockExchange.update_price("RELIANCE", 2510)  # Crosses high threshold!
:timer.sleep(80)

# Price drops
StockExchange.update_price("TCS", 3600)
:timer.sleep(80)
StockExchange.update_price("TCS", 3480)  # Crosses low threshold!
:timer.sleep(100)

IO.puts("""

═══════════════════════════════════════════════════════════════════
                        REAL WORLD INSIGHTS
═══════════════════════════════════════════════════════════════════

OBSERVER TYPES (Same Event, Different Reactions):

1. DisplayBoard:
   - Simply displays current prices
   - No complex logic, just visualization

2. PriceAlertSystem:
   - Compares prices against thresholds
   - Only acts when conditions are met
   - Could trigger trades, send emails, etc.

3. TradeLogger:
   - Records every single change
   - Calculates percentage changes
   - Used for audit trails

WHY THIS IS POWERFUL:

✅ Add new observer types without changing StockExchange
✅ Each observer has its own logic and state
✅ Observers can filter which events they care about
✅ Easy to test each component independently
✅ Scales well - can have thousands of observers

IN PRODUCTION, YOU MIGHT SEE:
- PhoenixPubSub for distributed systems
- GenStage for backpressure handling
- Broadway for data pipelines
""")
