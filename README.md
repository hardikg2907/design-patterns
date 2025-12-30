# Design Patterns in Elixir 🧩

A hands-on learning project for understanding and implementing classic design patterns using **Elixir**.

---

## 📚 About This Project

This repository contains practical examples of design patterns adapted for functional programming in Elixir. Each pattern includes:

- **OOP Reference** — Traditional object-oriented explanation with UML diagrams
- **Elixir Adaptation** — How the pattern translates to functional programming
- **Interactive Examples** — Hands-on code you can run and modify
- **Real-World Use Cases** — Practical applications you'd encounter in production

---

## 🗂️ Patterns Covered

| Pattern | Category | Status |
|---------|----------|--------|
| [Strategy](./strategy_pattern/) | Behavioral | ✅ Complete |
| [Observer](./observer_pattern/) | Behavioral | ✅ Complete |

---

## 📁 Project Structure

```
design-patterns/
├── README.md                    # This file
├── GEMINI.md                    # Learning guidelines
└── pattern_name/
    ├── README.md               # Pattern overview (Elixir-focused)
    ├── OOP_REFERENCE.md        # Traditional OOP explanation
    ├── basic_example.exs       # Simple interactive example
    ├── generalized_example.exs # Reusable template
    └── real_world_example.exs  # Production-like example
```

---

## 🚀 Getting Started

### Prerequisites
- [Elixir](https://elixir-lang.org/install.html) installed on your system

### Running Examples

```bash
# Navigate to a pattern folder
cd strategy_pattern

# Run any example
elixir basic_example.exs
elixir real_world_example.exs

# Interactive mode (drop into IEx shell after running)
iex basic_example.exs
```

---

## 🎯 Learning Approach

1. **Read the OOP Reference** — Understand the traditional pattern
2. **Read the README** — See how it adapts to Elixir
3. **Run the Basic Example** — Get hands-on with simple code
4. **Try the Exercises** — Reinforce your understanding
5. **Study the Real-World Example** — See practical applications

---

## 📖 Pattern Categories

### Creational Patterns
> Deal with object creation mechanisms

- Factory, Abstract Factory, Builder, Singleton, Prototype

### Structural Patterns
> Deal with object composition

- Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy

### Behavioral Patterns
> Deal with object communication

- **Strategy** ✅, **Observer** 🚧, Command, State, Template Method, Iterator, Mediator, Memento, Visitor, Chain of Responsibility

---

## 🔧 Elixir-Specific Notes

Traditional OOP patterns often need adaptation for functional programming:

| OOP Concept | Elixir Equivalent |
|-------------|-------------------|
| Interface | `@behaviour` + `@callback` |
| Class | Module |
| Object with state | GenServer / Agent |
| Inheritance | Composition + Protocols |
| Polymorphism | Pattern matching / Behaviours |

---

## 📝 License

This project is for educational purposes. Feel free to use and modify!

---

*Happy learning! 🎓*
