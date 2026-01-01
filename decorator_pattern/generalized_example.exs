# =============================================================================
# Decorator Pattern - Generalized/Reusable Template
# =============================================================================
# A direct translation of the OOP Decorator pattern to Elixir.
# This shows the abstract pattern structure that can be applied to ANY use case.
#
# Run: elixir generalized_example.exs
# =============================================================================

# =============================================================================
# OOP PATTERN TRANSLATION
# =============================================================================
#
# OOP Participants:
#   - Component (interface)      -> @callback in behaviour
#   - ConcreteComponent          -> Module implementing the behaviour
#   - Decorator (abstract)       -> Higher-order function / wrapper module
#   - ConcreteDecorator          -> Specific decorator implementations
#
# =============================================================================

# =============================================================================
# APPROACH 1: Behaviour-based (Closest to OOP)
# =============================================================================

defmodule Component do
  @moduledoc """
  The Component interface (OOP equivalent).
  Defines the contract that both concrete components and decorators must follow.
  """

  @callback operation(data :: any()) :: any()
end

defmodule ConcreteComponent do
  @moduledoc """
  The base concrete component (OOP equivalent).
  This is the object we're decorating.
  """
  @behaviour Component

  @impl Component
  def operation(data) do
    # The core business logic
    "ConcreteComponent processed: #{inspect(data)}"
  end
end

defmodule Decorator do
  @moduledoc """
  Abstract Decorator (OOP equivalent).
  Wraps a component and delegates to it.
  In Elixir, we use higher-order functions or module references.
  """

  @doc """
  Wraps a component module with a decorator module.
  Both must implement the Component behaviour.
  """
  def wrap(component_module, decorator_module) do
    # Return a function that acts like the decorated component
    fn data -> decorator_module.operation(data, component_module) end
  end
end

defmodule ConcreteDecoratorA do
  @moduledoc """
  Concrete Decorator A - adds behavior BEFORE the wrapped operation.
  Example: Logging, validation, preprocessing.
  """
  @behaviour Component

  @impl Component
  def operation(data) do
    operation(data, ConcreteComponent)
  end

  def operation(data, wrapped_component) do
    # Add behavior BEFORE
    IO.puts("[DecoratorA] Pre-processing: #{inspect(data)}")

    # Delegate to wrapped component
    result = wrapped_component.operation(data)

    # Return result (could also add post-processing)
    result
  end
end

defmodule ConcreteDecoratorB do
  @moduledoc """
  Concrete Decorator B - adds behavior AFTER the wrapped operation.
  Example: Timing, result transformation, post-processing.
  """
  @behaviour Component

  @impl Component
  def operation(data) do
    operation(data, ConcreteComponent)
  end

  def operation(data, wrapped_component) do
    start_time = System.monotonic_time(:microsecond)

    # Delegate to wrapped component
    result = wrapped_component.operation(data)

    # Add behavior AFTER
    duration = System.monotonic_time(:microsecond) - start_time
    IO.puts("[DecoratorB] Operation took #{duration}μs")

    result
  end
end

# =============================================================================
# APPROACH 2: Function Composition (More Idiomatic Elixir)
# =============================================================================

defmodule FunctionalDecorator do
  @moduledoc """
  Functional approach using higher-order functions.
  This is more idiomatic in Elixir.
  """

  # Base operation (ConcreteComponent equivalent)
  def base_operation(data) do
    "Processed: #{inspect(data)}"
  end

  # Decorator factory: wraps any function with logging
  def with_logging(func, label \\ "operation") do
    fn data ->
      IO.puts("[LOG] Before #{label}: #{inspect(data)}")
      result = func.(data)
      IO.puts("[LOG] After #{label}: #{inspect(result)}")
      result
    end
  end

  # Decorator factory: wraps any function with timing
  def with_timing(func) do
    fn data ->
      start = System.monotonic_time(:microsecond)
      result = func.(data)
      IO.puts("[TIME] Duration: #{System.monotonic_time(:microsecond) - start}μs")
      result
    end
  end

  # Decorator factory: wraps any function with validation
  def with_validation(func, validator) do
    fn data ->
      if validator.(data) do
        func.(data)
      else
        {:error, "Validation failed for: #{inspect(data)}"}
      end
    end
  end

  # Decorator factory: transforms the result
  def with_transform(func, transform) do
    fn data ->
      result = func.(data)
      transform.(result)
    end
  end
end

# =============================================================================
# APPROACH 3: Pipeline/Data Decorators (For Data Transformation)
# =============================================================================

defmodule PipelineDecorator do
  @moduledoc """
  When decoration adds metadata or wraps data in a structure.
  Similar to request/response wrappers.
  """

  defstruct [:value, :metadata]

  # Create a wrapped value (ConcreteComponent)
  def new(value) do
    %__MODULE__{value: value, metadata: %{}}
  end

  # Extract the final value
  def unwrap(%__MODULE__{value: value}), do: value

  # Decorator: add timestamp metadata
  def with_timestamp(%__MODULE__{} = wrapper) do
    %{wrapper | metadata: Map.put(wrapper.metadata, :timestamp, DateTime.utc_now())}
  end

  # Decorator: add tag metadata
  def with_tag(%__MODULE__{} = wrapper, tag) do
    tags = Map.get(wrapper.metadata, :tags, [])
    %{wrapper | metadata: Map.put(wrapper.metadata, :tags, [tag | tags])}
  end

  # Decorator: transform the value
  def transform(%__MODULE__{} = wrapper, func) do
    %{wrapper | value: func.(wrapper.value)}
  end

  # Decorator: validate value
  def validate(%__MODULE__{} = wrapper, validator) do
    valid? = validator.(wrapper.value)
    %{wrapper | metadata: Map.put(wrapper.metadata, :valid, valid?)}
  end
end

# =============================================================================
# DEMONSTRATION
# =============================================================================

IO.puts("""
╔═══════════════════════════════════════════════════════════════════╗
║         DECORATOR PATTERN - Generalized Template                  ║
╚═══════════════════════════════════════════════════════════════════╝
""")

# -----------------------------------------------------------------------------
# Demo 1: Behaviour-based (OOP Translation)
# -----------------------------------------------------------------------------

IO.puts("━━━ Demo 1: Behaviour-based Decorators (OOP Style) ━━━\n")

# Direct usage
IO.puts("ConcreteComponent alone:")
IO.puts("   " <> ConcreteComponent.operation("hello"))

IO.puts("\nWith DecoratorA (pre-processing):")
IO.puts("   " <> ConcreteDecoratorA.operation("hello", ConcreteComponent))

IO.puts("\nWith DecoratorB (timing):")
IO.puts("   " <> ConcreteDecoratorB.operation("hello", ConcreteComponent))

IO.puts("\nStacked: DecoratorB wrapping DecoratorA wrapping ConcreteComponent:")
# Create a "pseudo-module" for stacking
decorated = Decorator.wrap(ConcreteComponent, ConcreteDecoratorA)
# For demo, manually stack
result =
  fn data ->
    IO.puts("[DecoratorB] Starting timing...")
    start = System.monotonic_time(:microsecond)
    res = ConcreteDecoratorA.operation(data, ConcreteComponent)
    IO.puts("[DecoratorB] Duration: #{System.monotonic_time(:microsecond) - start}μs")
    res
  end

IO.puts("   " <> result.("world"))

# -----------------------------------------------------------------------------
# Demo 2: Function Composition (Idiomatic Elixir)
# -----------------------------------------------------------------------------

IO.puts("\n━━━ Demo 2: Function Composition (Idiomatic Elixir) ━━━\n")

# Stack decorators by composing functions
decorated_fn =
  (&FunctionalDecorator.base_operation/1)
  |> FunctionalDecorator.with_validation(&is_binary/1)
  |> FunctionalDecorator.with_logging("process")
  |> FunctionalDecorator.with_timing()

IO.puts("Calling decorated function:")
result = decorated_fn.("Hello, Decorator Pattern!")
IO.puts("Final result: #{result}")

IO.puts("\nWith invalid input (fails validation):")
invalid_result = decorated_fn.(12345)
IO.puts("Result: #{inspect(invalid_result)}")

# -----------------------------------------------------------------------------
# Demo 3: Pipeline Decorators
# -----------------------------------------------------------------------------

IO.puts("\n━━━ Demo 3: Pipeline Decorators (Data Transformation) ━━━\n")

result =
  "hello world"
  |> PipelineDecorator.new()
  |> PipelineDecorator.with_timestamp()
  |> PipelineDecorator.with_tag(:important)
  |> PipelineDecorator.with_tag(:processed)
  |> PipelineDecorator.transform(&String.upcase/1)
  |> PipelineDecorator.validate(&(String.length(&1) > 5))

IO.puts("Wrapped value: #{result.value}")
IO.puts("Metadata: #{inspect(result.metadata)}")

# =============================================================================
# SUMMARY
# =============================================================================

IO.puts("""

═══════════════════════════════════════════════════════════════════
                     APPROACH COMPARISON
═══════════════════════════════════════════════════════════════════

┌──────────────────────┬────────────────────────────────────────────┐
│ Approach             │ When to Use                                │
├──────────────────────┼────────────────────────────────────────────┤
│ Behaviour-based      │ When you need OOP-like structure,          │
│                      │ formal contracts, module-based decorators  │
├──────────────────────┼────────────────────────────────────────────┤
│ Function Composition │ Most idiomatic for Elixir, simple          │
│                      │ decorators, quick and flexible             │
├──────────────────────┼────────────────────────────────────────────┤
│ Pipeline/Data        │ When decorating data structures,           │
│                      │ adding metadata, request/response chains   │
└──────────────────────┴────────────────────────────────────────────┘

OOP TO ELIXIR MAPPING:
  Component interface     →  @callback in behaviour
  ConcreteComponent       →  Module implementing behaviour
  Abstract Decorator      →  Higher-order function / wrapper module
  ConcreteDecorator       →  Specific decorator function/module
  Wrapping (new D(obj))   →  Function composition / pipe operator
""")
