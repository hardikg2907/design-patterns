# ============================================================
# DECORATOR PATTERN - Basic Example: Coffee Shop
# ============================================================
#
# Let's build a coffee shop where you can add toppings to your drink!
# Each topping is a "decorator" that wraps around the base coffee.
#
# This is a FUN and TASTY way to learn the Decorator pattern! ☕

defmodule CoffeeShop do
  @moduledoc """
  A simple coffee shop demonstrating the Decorator pattern.

  In OOP, you'd have:
  - Coffee interface
  - BasicCoffee class
  - MilkDecorator, SugarDecorator, WhippedCreamDecorator classes

  In Elixir, we use:
  - A data structure (map) to represent coffee
  - Functions that take coffee and return enhanced coffee
  """

  # ============================================================
  # STEP 1: The Base Component (BasicCoffee)
  # ============================================================

  @doc """
  Creates a basic coffee - this is our ConcreteComponent.
  Returns a map with description and cost.
  """
  def basic_coffee do
    %{
      description: "Basic Coffee",
      cost: 2.00,
      ingredients: ["coffee", "water"]
    }
  end

  def espresso do
    %{
      description: "Espresso",
      cost: 2.50,
      ingredients: ["espresso"]
    }
  end

  # ============================================================
  # STEP 2: Decorators (Toppings)
  # ============================================================
  # Each decorator takes a coffee and returns an enhanced coffee.
  # This is the heart of the Decorator pattern in FP!

  @doc "Adds milk to any coffee"
  def with_milk(coffee) do
    %{
      description: coffee.description <> " + Milk",
      cost: coffee.cost + 0.50,
      ingredients: coffee.ingredients ++ ["milk"]
    }
  end

  @doc "Adds sugar to any coffee"
  def with_sugar(coffee) do
    %{
      description: coffee.description <> " + Sugar",
      cost: coffee.cost + 0.25,
      ingredients: coffee.ingredients ++ ["sugar"]
    }
  end

  @doc "Adds whipped cream to any coffee"
  def with_whipped_cream(coffee) do
    %{
      description: coffee.description <> " + Whipped Cream",
      cost: coffee.cost + 0.75,
      ingredients: coffee.ingredients ++ ["whipped cream"]
    }
  end

  @doc "Adds caramel to any coffee"
  def with_caramel(coffee) do
    %{
      description: coffee.description <> " + Caramel",
      cost: coffee.cost + 0.60,
      ingredients: coffee.ingredients ++ ["caramel"]
    }
  end

  @doc "Makes it a double shot"
  def make_double(coffee) do
    %{
      description: "Double " <> coffee.description,
      cost: coffee.cost + 1.00,
      ingredients: coffee.ingredients ++ ["extra shot"]
    }
  end

  def with_vanilla(coffee) do
    %{
      description: coffee.description,
      cost: coffee.cost + 0.4,
      ingredients: coffee.ingredients ++ ["vanilla"]
    }
  end

  def with_size(coffee, size) do
    %{
      description:
        case size do
          :small -> coffee.description
          :medium -> "Medium " <> coffee.description
          :large -> "Large " <> coffee.description
        end,
      cost:
        case size do
          :small -> coffee.cost
          :medium -> coffee.cost + 0.5
          :large -> coffee.cost + 1
        end,
      ingredients: coffee.ingredients
    }
  end

  # ============================================================
  # STEP 3: Helper to display orders
  # ============================================================

  def display_order(coffee) do
    IO.puts("\n☕ ORDER DETAILS:")
    IO.puts("   Description: #{coffee.description}")
    IO.puts("   Cost: $#{:erlang.float_to_binary(coffee.cost, decimals: 2)}")
    IO.puts("   Ingredients: #{Enum.join(coffee.ingredients, ", ")}")
    coffee
  end
end

# ============================================================
# LET'S TRY IT OUT!
# ============================================================

IO.puts("=" |> String.duplicate(60))
IO.puts("☕ WELCOME TO THE ELIXIR COFFEE SHOP! ☕")
IO.puts("=" |> String.duplicate(60))

# Order 1: Simple coffee with milk
IO.puts("\n📋 Order #1: Basic coffee with milk")

CoffeeShop.basic_coffee()
|> CoffeeShop.with_milk()
|> CoffeeShop.display_order()

# Order 2: Fancy coffee - stacking decorators!
IO.puts("\n📋 Order #2: Fancy latte (milk + sugar + whipped cream)")

CoffeeShop.basic_coffee()
|> CoffeeShop.with_milk()
|> CoffeeShop.with_sugar()
|> CoffeeShop.with_whipped_cream()
|> CoffeeShop.display_order()

# Order 3: Double espresso with caramel
IO.puts("\n📋 Order #3: Double caramel espresso")

CoffeeShop.espresso()
|> CoffeeShop.make_double()
|> CoffeeShop.with_caramel()
|> CoffeeShop.with_whipped_cream()
|> CoffeeShop.display_order()

IO.puts("\n📋 Order #4: Double caramel espresso with vanilla")

CoffeeShop.espresso()
|> CoffeeShop.make_double()
|> CoffeeShop.with_caramel()
|> CoffeeShop.with_whipped_cream()
|> CoffeeShop.with_vanilla()
|> CoffeeShop.display_order()

# ============================================================
# 🎯 YOUR TURN! Try these exercises:
# ============================================================

IO.puts("\n" <> String.duplicate("=", 60))
IO.puts("🎯 YOUR TURN - EXERCISES!")
IO.puts(String.duplicate("=", 60))

IO.puts("""

Exercise 1: Create a new decorator function called `with_vanilla`
            that adds 0.40 to the cost and "vanilla" to ingredients.

Exercise 2: Create an order that uses at least 4 different decorators.

Exercise 3: Create a function `with_size(coffee, size)` that:
            - :small -> no change
            - :medium -> +0.50 cost, adds "medium" to description
            - :large -> +1.00 cost, adds "large" to description

TIP: Each decorator is just a function that takes coffee, transforms it,
     and returns the new coffee. It's that simple!
""")

# ============================================================
# 🔑 KEY TAKEAWAYS
# ============================================================

IO.puts(String.duplicate("=", 60))
IO.puts("🔑 KEY TAKEAWAYS")
IO.puts(String.duplicate("=", 60))

IO.puts("""

1. DECORATOR = A function that wraps another "thing" and adds behavior

2. In Elixir, the pipe operator (|>) makes decorating beautiful:
   base_thing |> decorate1() |> decorate2() |> decorate3()

3. Each decorator is INDEPENDENT - you can mix and match freely

4. The ORDER of decorators can matter (like "Double" before vs after "Milk")

5. Compare to OOP:
   - OOP: new WhippedCreamDecorator(new MilkDecorator(new Coffee()))
   - Elixir: coffee() |> with_milk() |> with_whipped_cream()

   Much cleaner, right? 😎
""")
