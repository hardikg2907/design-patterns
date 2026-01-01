# Decorator Pattern in Elixir

## What is the Decorator Pattern?

The **Decorator Pattern** is a structural design pattern that allows you to dynamically add new behaviors or responsibilities to an object without modifying its original code. Think of it as wrapping a gift — you can add layer after layer of wrapping paper, each adding something new to the presentation without changing the gift inside.

## What Problem Does It Solve?

- **Avoiding class explosion**: Instead of creating multiple subclasses for every combination of features, you wrap objects with decorators
- **Open/Closed Principle**: Add new functionality without modifying existing code
- **Single Responsibility Principle**: Divide functionality into smaller, focused classes/modules
- **Runtime flexibility**: Add or remove behaviors dynamically at runtime

## When Should You Use It?

- When you need to add responsibilities to objects dynamically and transparently
- When extension by subclassing is impractical (too many combinations)
- When you want to add features that can be withdrawn later
- When you need behaviors to be combined in various ways

## Key Components

| OOP Term | Elixir Equivalent |
|----------|-------------------|
| Component Interface | Function signature or Behaviour |
| Concrete Component | Base function/module with core functionality |
| Decorator | Higher-order function that wraps the component |
| Concrete Decorator | Specific wrapper function adding new behavior |

## Elixir-Specific Approaches

In Elixir, the Decorator pattern can be implemented using several techniques:

1. **Function Composition** - Wrap functions with other functions using pipe operator
2. **Higher-order Functions** - Functions that take functions and return enhanced versions
3. **Macros** - Compile-time decoration using metaprogramming (like `@decorate`)
4. **Protocol Extension** - Extend behaviors for specific data types

### Why Decorator is Natural in Elixir

Elixir's functional nature makes decorating trivial! In OOP, you need interfaces and inheritance. In Elixir, you simply:

```elixir
# Compose functions with pipes
data
|> base_operation()
|> add_logging()
|> add_timing()
|> add_validation()
```

---

## Files in This Directory

- `basic_example.exs` - Simple interactive example (coffee shop with toppings!)
- `generalized_example.exs` - Reusable pattern template
- `real_world_example.exs` - HTTP request middleware system
- `OOP_REFERENCE.md` - Traditional OOP format explanation
