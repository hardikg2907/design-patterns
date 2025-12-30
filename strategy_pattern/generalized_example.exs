# Strategy Pattern - Generalized Example
# A reusable template showing Strategy pattern with Behaviours

# =============================================================================
# USING BEHAVIOURS FOR MORE FORMAL STRATEGY PATTERN
# =============================================================================
#
# Behaviours in Elixir provide a way to:
# - Define a set of functions that a module must implement
# - Ensure compile-time checks for strategy implementations
# - Create a clear "contract" like interfaces in OOP

# Define the Strategy behaviour (the "interface")
defmodule Strategy do
  @callback execute(any()) :: any()
end

# Concrete Strategy A
defmodule StrategyA do
  @behaviour Strategy

  @impl Strategy
  def execute(data) do
    "Strategy A processed: #{inspect(data)}"
  end
end

# Concrete Strategy B
defmodule StrategyB do
  @behaviour Strategy

  @impl Strategy
  def execute(data) do
    "Strategy B transformed: #{String.upcase(to_string(data))}"
  end
end

# Context module that uses strategies
defmodule Context do
  # Option 1: Pass strategy module directly
  def run(data, strategy_module) when is_atom(strategy_module) do
    strategy_module.execute(data)
  end

  # Option 2: Pass strategy as a function
  def run_with_fn(data, strategy_fn) when is_function(strategy_fn, 1) do
    strategy_fn.(data)
  end
end

# =============================================================================
# DEMONSTRATION
# =============================================================================

IO.puts("=== Generalized Strategy Pattern ===\n")

# Using module-based strategies
IO.puts("Using StrategyA module:")
IO.puts(Context.run("hello world", StrategyA))

IO.puts("\nUsing StrategyB module:")
IO.puts(Context.run("hello world", StrategyB))

# Using function-based strategies (more flexible)
IO.puts("\n--- Using anonymous functions ---")

reverse_strategy = fn data -> "Reversed: #{String.reverse(to_string(data))}" end
IO.puts(Context.run_with_fn("hello world", reverse_strategy))

# You can even compose strategies!
composed = fn data ->
  data
  |> to_string()
  |> String.upcase()
  |> String.reverse()
end
IO.puts("Composed strategy: #{Context.run_with_fn("hello", composed)}")
