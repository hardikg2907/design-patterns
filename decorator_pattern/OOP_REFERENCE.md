# Decorator Pattern — OOP Reference

This document shows the traditional Object-Oriented Programming format for the Decorator pattern, as described in the Gang of Four book. This helps understand how the pattern is typically implemented in languages like Java, C++, or C#, and provides a reference point for how we adapt it to Elixir's functional paradigm.

---

## UML Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              «interface»                                 │
│                              Component                                   │
├─────────────────────────────────────────────────────────────────────────┤
│ + operation(): Result                                                    │
└─────────────────────────────────────────────────────────────────────────┘
                    △                              △
                    │                              │
                    │                              │
     ┌──────────────┴──────────────┐    ┌─────────┴────────────────────┐
     │     ConcreteComponent       │    │        Decorator              │
     ├─────────────────────────────┤    ├───────────────────────────────┤
     │                             │    │ - component: Component        │
     ├─────────────────────────────┤    ├───────────────────────────────┤
     │ + operation(): Result       │    │ + operation(): Result         │
     │   // base implementation    │    │   // delegates to component   │
     └─────────────────────────────┘    └───────────────────────────────┘
                                                       △
                                                       │
                    ┌──────────────────────────────────┼──────────────────┐
                    │                                  │                  │
     ┌──────────────┴──────────────┐    ┌─────────────┴───────┐   ┌──────┴─────────┐
     │    ConcreteDecoratorA       │    │ ConcreteDecoratorB  │   │     ...        │
     ├─────────────────────────────┤    ├─────────────────────┤   └────────────────┘
     │ - addedState                │    │                     │
     ├─────────────────────────────┤    ├─────────────────────┤
     │ + operation(): Result       │    │ + operation(): Result│
     │ + addedBehavior()           │    │ + addedBehavior()   │
     └─────────────────────────────┘    └─────────────────────┘
```

---

## Participants

| Participant | Role |
|-------------|------|
| **Component** | Defines the interface for objects that can have responsibilities added dynamically |
| **ConcreteComponent** | The original object to which we want to add new behavior |
| **Decorator** | Maintains a reference to a Component and defines an interface conforming to Component's interface |
| **ConcreteDecorator** | Adds responsibilities to the component. Can add state or behavior |

---

## Pseudocode (OOP Style)

```
// The common interface for both base components and decorators
INTERFACE Component
    METHOD operation() -> Result
END INTERFACE

// Base concrete implementation
CLASS ConcreteComponent IMPLEMENTS Component
    METHOD operation() -> Result
        // Core business logic
        RETURN baseResult
    END METHOD
END CLASS

// Abstract decorator - holds reference to wrapped component
ABSTRACT CLASS Decorator IMPLEMENTS Component
    PROTECTED field wrappedComponent: Component
    
    CONSTRUCTOR(component: Component)
        this.wrappedComponent = component
    END CONSTRUCTOR
    
    METHOD operation() -> Result
        // Delegate to wrapped component
        RETURN wrappedComponent.operation()
    END METHOD
END CLASS

// Concrete decorator adding specific behavior
CLASS LoggingDecorator EXTENDS Decorator
    CONSTRUCTOR(component: Component)
        SUPER(component)
    END CONSTRUCTOR
    
    METHOD operation() -> Result
        log("Before operation")
        result = SUPER.operation()
        log("After operation: " + result)
        RETURN result
    END METHOD
END CLASS

// Another concrete decorator
CLASS TimingDecorator EXTENDS Decorator
    CONSTRUCTOR(component: Component)
        SUPER(component)
    END CONSTRUCTOR
    
    METHOD operation() -> Result
        startTime = currentTime()
        result = SUPER.operation()
        endTime = currentTime()
        log("Duration: " + (endTime - startTime))
        RETURN result
    END METHOD
END CLASS

// Usage - decorators can be stacked!
component = new ConcreteComponent()
logged = new LoggingDecorator(component)
loggedAndTimed = new TimingDecorator(logged)

loggedAndTimed.operation()
// Output:
// Before operation
// Duration: 42ms
// After operation: result
```

---

## Key OOP Concepts Used

| Concept | How It's Used |
|---------|---------------|
| **Interface** | Component interface ensures decorators and components are interchangeable |
| **Composition** | Decorators hold a reference to the wrapped object (has-a relationship) |
| **Inheritance** | All decorators inherit from the abstract Decorator class |
| **Polymorphism** | Client code works with Component interface, unaware of decorators |
| **Single Responsibility** | Each decorator handles one specific concern |
| **Delegation** | Decorators delegate to wrapped components |

---

## Comparison: OOP vs Elixir

| Aspect | OOP | Elixir |
|--------|-----|--------|
| **Component Interface** | Abstract class or interface | Behaviour / function signature |
| **Wrapping** | Object composition with inheritance | Function composition / higher-order functions |
| **State** | Instance variables in decorator class | Data passed through function pipeline |
| **Adding Decorators** | Create new decorator instances | Compose functions or use macros |
| **Chaining** | Nested constructor calls | Pipe operator `\|>` |
| **Type Safety** | Interface implementation | Behaviours or typespecs |
| **Runtime vs Compile-time** | Runtime only | Both (macros for compile-time) |

### OOP Style Chaining:
```java
new TimingDecorator(
    new LoggingDecorator(
        new ValidationDecorator(
            new BaseComponent()
        )
    )
).operation()
```

### Elixir Style Chaining:
```elixir
data
|> base_operation()
|> with_validation()
|> with_logging()
|> with_timing()
```

---

## When to Apply (Gang of Four)

Use the Decorator pattern when:

- You want to add responsibilities to individual objects dynamically without affecting other objects
- You want to add responsibilities that can be withdrawn
- Extension by subclassing is impractical due to a large number of independent extensions
- You need transparent wrapping (decorated object should work like the original)

---

## Related Patterns

| Pattern | Relationship |
|---------|--------------|
| **Adapter** | Adapter changes interface, Decorator keeps it the same |
| **Composite** | Decorator is a special Composite with only one component |
| **Strategy** | Decorator changes the "skin" (wraps), Strategy changes the "guts" (replaces) |
| **Proxy** | Proxy controls access, Decorator adds behavior |
| **Chain of Responsibility** | Similar structure but different intent; CoR can stop chain |
