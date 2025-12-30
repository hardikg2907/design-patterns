# Strategy Pattern - Basic Example: Shipping Cost Calculator
# This example demonstrates how different shipping strategies can be swapped at runtime

# =============================================================================
# GENERAL STRUCTURE OF STRATEGY PATTERN IN ELIXIR
# =============================================================================
#
#   1. Define strategies as functions (or modules with a common behaviour)
#   2. Create a context that accepts a strategy function as an argument
#   3. The context calls the strategy function to perform the operation
#
#   +-------------------+       +-------------------+
#   |     Context       |  -->  |     Strategy      |
#   | (uses a strategy) |       | (function/module) |
#   +-------------------+       +-------------------+
#                                      ^
#                                      |
#                    +-----------------+-----------------+
#                    |                 |                 |
#             +-----------+     +-----------+     +-----------+
#             | Strategy1 |     | Strategy2 |     | Strategy3 |
#             +-----------+     +-----------+     +-----------+
#
# =============================================================================

defmodule ShippingCalculator do
  # STRATEGIES - Different shipping methods
  # Each strategy is a simple function that takes weight and returns cost

  def standard_shipping(weight) do
    # $5 base + $0.50 per kg
    5.0 + (weight * 0.5)
  end

  def express_shipping(weight) do
    # $15 base + $1.00 per kg
    15.0 + (weight * 1.0)
  end

  def overnight_shipping(weight) do
    # $25 base + $2.00 per kg
    25.0 + (weight * 2.0)
  end

  def economy_shipping(weight) do
    # $0 base + $0.25 per kg
    0.0 + (weight * 0.25)
  end

  # CONTEXT - The function that uses a strategy
  # Notice how `strategy` is passed as a function argument!
  def calculate_cost(weight, strategy) do
    strategy.(weight)
  end
end

# =============================================================================
# LET'S TRY IT OUT!
# =============================================================================

weight = 10  # 10 kg package

IO.puts("=== Shipping Cost Calculator ===")
IO.puts("Package weight: #{weight} kg\n")

# Using different strategies for the same weight
standard_cost = ShippingCalculator.calculate_cost(weight, &ShippingCalculator.standard_shipping/1)
IO.puts("Standard Shipping: $#{standard_cost}")

express_cost = ShippingCalculator.calculate_cost(weight, &ShippingCalculator.express_shipping/1)
IO.puts("Express Shipping:  $#{express_cost}")

overnight_cost = ShippingCalculator.calculate_cost(weight, &ShippingCalculator.overnight_shipping/1)
IO.puts("Overnight Shipping: $#{overnight_cost}")

economy_cost = ShippingCalculator.calculate_cost(weight, &ShippingCalculator.economy_shipping/1)
IO.puts("Economy Shipping: $#{economy_cost}")

# =============================================================================
# INTERACTIVE EXERCISE
# =============================================================================

IO.puts("\n=== YOUR TURN! ===")
IO.puts("""
Try adding a new strategy called 'economy_shipping' that:
- Has NO base cost ($0)
- Charges $0.25 per kg

Steps:
1. Add a new function `economy_shipping/1` to the ShippingCalculator module
2. Test it by calling: ShippingCalculator.calculate_cost(10, &ShippingCalculator.economy_shipping/1)

Run this file with: elixir basic_example.exs
""")
