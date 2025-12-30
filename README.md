# Design Patterns in Elixir 🎨

A comprehensive learning repository for understanding and implementing design patterns using **Elixir**, a functional programming language. This project adapts traditional object-oriented design patterns to functional programming paradigms.

## 📚 Overview

This repository serves as an interactive guide for learning design patterns through:
- **Clear explanations** of each pattern's purpose and use cases
- **Multiple examples** ranging from simple to production-ready implementations
- **Hands-on exercises** to reinforce learning
- **Elixir-specific adaptations** showing how OOP patterns translate to functional programming

## 🎯 Purpose

Design patterns provide proven solutions to common software design problems. While many patterns originated in object-oriented programming, this project demonstrates how to apply these concepts effectively in Elixir's functional, concurrent environment.

## 🚀 Getting Started

### Prerequisites

- **Elixir** 1.12 or later ([Installation Guide](https://elixir-lang.org/install.html))
- Basic understanding of Elixir syntax and functional programming concepts

### Installation

Clone the repository:

```bash
git clone https://github.com/hardikg2907/design-patterns.git
cd design-patterns
```

No additional dependencies are required! All examples use only Elixir's standard library.

## 📁 Project Structure

```
design-patterns/
├── README.md                    # This file
├── GEMINI.md                    # Learning guidelines and format
├── pattern_name/                # Each pattern has its own folder
│   ├── README.md               # Pattern overview and explanation
│   ├── basic_example.exs       # Simple, beginner-friendly example
│   ├── generalized_example.exs # Abstract/reusable implementation
│   ├── real_world_example.exs  # Production-like use case
│   └── exercises/              # Optional practice exercises
│       └── exercise_1.exs
```

## 🎨 Currently Implemented Patterns

### Behavioral Patterns

- **[Strategy Pattern](./strategy_pattern/)** - Define a family of algorithms, encapsulate each one, and make them interchangeable at runtime
  - Basic: Shipping cost calculator
  - Real-world: Payment processing system

_More patterns coming soon!_

## 🏃 How to Run Examples

Each pattern folder contains `.exs` (Elixir script) files that can be executed directly:

```bash
# Run a specific example
elixir strategy_pattern/basic_example.exs

# Or start an interactive session
iex strategy_pattern/basic_example.exs
```

### Interactive REPL

For experimentation, use `iex` (Interactive Elixir):

```bash
# Start interactive shell
iex

# Load and run a file
iex> c("strategy_pattern/basic_example.exs")
```

## 📖 Learning Approach

Each pattern follows a structured learning format:

1. **Research** - Understanding the pattern's history and applications
2. **Brief Overview** - What, why, and when to use it
3. **General Structure** - Components and their roles
4. **Easy Interactive Example** - Simple, hands-on introduction
5. **Generalized Example** - Abstract, reusable implementation
6. **Real-World Example** - Practical, production-like scenario

See [GEMINI.md](./GEMINI.md) for detailed learning guidelines.

## 🔑 Key Concepts

### Adapting OOP Patterns to Elixir

Elixir is a functional language, so traditional OOP patterns are adapted using:

- **Higher-order functions** - Pass functions as arguments (Strategy, Command)
- **Pattern matching** - Select behavior based on data structure
- **Behaviours** - Define contracts similar to interfaces
- **Processes** - Leverage concurrency for state management (Singleton → GenServer)
- **Protocols** - Polymorphism for different data types

## 🤝 Contributing

Contributions are welcome! To add a new pattern:

1. Create a folder using `snake_case` naming (e.g., `observer_pattern`)
2. Follow the structure outlined in [GEMINI.md](./GEMINI.md)
3. Include all three examples (basic, generalized, real-world)
4. Add a comprehensive README for the pattern
5. Update this main README with the new pattern

## 📝 License

This project is open source and available for educational purposes.

## 🙏 Acknowledgments

- Design pattern concepts from the Gang of Four (GoF)
- Elixir community for functional programming insights
- Contributors who help expand this learning resource

## 📬 Contact

For questions or suggestions, please open an issue in the repository.

---

**Happy Learning!** 🎉

_Remember: The goal is not to memorize patterns, but to understand the problems they solve and when to apply them._
