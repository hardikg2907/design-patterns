# Design Patterns Learning Guide - Elixir

## Overview
This project is for studying and implementing various design patterns using **Elixir** as the primary language.

---

## Learning Format

When I specify a design pattern, follow this structured approach:

### 0. **Research (if needed)**
- Search the internet for relevant information about the pattern
- Look for Elixir-specific implementations or adaptations
- Gather best practices and common pitfalls

### 1. **Brief Overview**
- What is the pattern?
- What problem does it solve?
- When should you use it?
- Key participants/components

### 2. **General Format/Structure**
- Show the general structure/template of the pattern
- Explain the roles of each component

### 3. **Easy Interactive Example**
- Start with a simple, beginner-friendly example
- Make it interactive by:
  - Having me implement parts of the code
  - Running code and observing outputs
  - Asking me questions to reinforce understanding
  - Giving me small challenges/exercises

### 4. **Generalized Example**
- A more abstract/reusable implementation
- Shows how the pattern can be applied broadly, it should basically be a translation of the OOP reference to Elixir
- Check existing generalized examples files.

### 5. **Real-World Example**
- A practical, industry-relevant use case
- Something that demonstrates why this pattern matters in production code

---

## Project Structure

Each design pattern should be organized in its own folder:

```
design-patterns/
├── GEMINI.md                    # This file - guidelines and instructions
├── pattern_name/                # Folder for each pattern (snake_case)
│   ├── README.md               # Overview and notes for this pattern
│   ├── OOP_REFERENCE.md        # Traditional OOP format explanation
│   ├── basic_example.exs       # Simple interactive example
│   ├── generalized_example.exs # Reusable/abstract implementation
│   ├── real_world_example.exs  # Practical use case
│   └── exercises/              # Optional: practice exercises
│       └── exercise_1.exs
```

---

## Guidelines

1. **Language**: All implementations should be in Elixir
2. **File Extension**: Use `.exs` for script files (can be run with `elixir filename.exs`)
3. **Comments**: Include clear comments explaining the code but not too many
4. **Interactive Learning**: Prefer hands-on, step-by-step approach over just reading
5. **Elixir Idioms**: Adapt OOP patterns to functional programming where appropriate

---

## OOP_REFERENCE.md Structure

Each pattern's `OOP_REFERENCE.md` file should follow this consistent format:

```markdown
# [Pattern Name] — OOP Reference

[Brief intro explaining this shows the traditional OOP format]

---

## UML Diagram
[ASCII art UML showing the pattern structure]

---

## Participants
[Table with Participant | Role columns]

---

## Pseudocode (OOP Style)
[Language-agnostic pseudocode showing the pattern implementation]

---

## Key OOP Concepts Used
[Table showing Concept | How It's Used]

---

## Comparison: OOP vs Elixir
[Table comparing Aspect | OOP | Elixir approaches]

---

## When to Apply (Gang of Four)
[Bullet list of when to use this pattern]

---

## Related Patterns
[List of related patterns with brief explanation]
```

---

## Notes

- Elixir is a functional language, so some traditional OOP design patterns may need adaptation
- Focus on understanding the *intent* of patterns, not just the implementation
- Patterns covered: Strategy, Observer

---

## How to Run Elixir Files

```bash
# Run a script file
elixir filename.exs

# Start interactive shell
iex

# Run and drop into shell
iex filename.exs
```
