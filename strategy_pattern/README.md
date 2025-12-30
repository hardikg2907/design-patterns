# Strategy Pattern in Elixir

## What is the Strategy Pattern?

The **Strategy Pattern** is a behavioral design pattern that lets you define a family of algorithms, encapsulate each one, and make them interchangeable at runtime. The pattern allows the algorithm to vary independently from the clients that use it.

## What Problem Does It Solve?

- **Eliminates conditional statements**: Instead of using if/else or case statements to select behavior, you pass in the behavior directly
- **Open/Closed Principle**: You can add new strategies without modifying existing code
- **Runtime flexibility**: You can switch algorithms/behaviors at runtime

## When Should You Use It?

- When you have multiple algorithms that do similar things but in different ways
- When you want to avoid exposing complex, algorithm-specific data structures
- When a class has massive conditional statements that switch between variants of the same algorithm

## Key Components

| OOP Term | Elixir Equivalent |
|----------|-------------------|
| Strategy Interface | Function signature or Behaviour |
| Concrete Strategy | A function or module implementing the behaviour |
| Context | The module/function that uses the strategy |

## Elixir-Specific Approach

In Elixir, the Strategy pattern is naturally implemented using:

1. **Higher-order functions** - Pass functions as arguments
2. **Pattern matching** - Match on different inputs to select behavior
3. **Behaviours** - Define a contract that multiple modules can implement

---

## Files in This Directory

- `basic_example.exs` - Simple interactive example (shipping cost calculator)
- `generalized_example.exs` - Reusable pattern template
- `real_world_example.exs` - Payment processing system example
