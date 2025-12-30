# Strategy Pattern — OOP Reference

This document explains the Strategy pattern in its traditional **Object-Oriented Programming** format, so you can understand the original design before seeing the Elixir adaptation.

---

## UML Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────────┐         ┌──────────────────────────────────┐  │
│  │   Context   │         │    <<interface>> Strategy        │  │
│  ├─────────────┤         ├──────────────────────────────────┤  │
│  │ -strategy   │────────>│ + execute(data): result          │  │
│  ├─────────────┤         └──────────────────────────────────┘  │
│  │ +setStrategy│                       ▲                       │
│  │ +doWork()   │                       │                       │
│  └─────────────┘                       │                       │
│                     ┌──────────────────┼──────────────────┐    │
│                     │                  │                  │    │
│         ┌───────────┴───┐   ┌─────────┴────────┐   ┌─────┴───────────┐
│         │ ConcreteStratA│   │ ConcreteStratB   │   │ ConcreteStratC  │
│         ├───────────────┤   ├──────────────────┤   ├─────────────────┤
│         │ +execute()    │   │ +execute()       │   │ +execute()      │
│         └───────────────┘   └──────────────────┘   └─────────────────┘
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Participants

| Participant | Role |
|-------------|------|
| **Strategy** (Interface) | Declares the common interface for all algorithms |
| **ConcreteStrategy** | Implements the algorithm using the Strategy interface |
| **Context** | Maintains a reference to a Strategy object; calls Strategy's method |

---

## Pseudocode (OOP Style)

```plaintext
// The Strategy Interface
interface PaymentStrategy {
    method pay(amount: float): boolean
}

// Concrete Strategy A
class CreditCardPayment implements PaymentStrategy {
    private cardNumber: string
    
    constructor(cardNumber: string) {
        this.cardNumber = cardNumber
    }
    
    method pay(amount: float): boolean {
        print("Paid $" + amount + " using Credit Card ending in " + last4Digits())
        return true
    }
}

// Concrete Strategy B
class PayPalPayment implements PaymentStrategy {
    private email: string
    
    constructor(email: string) {
        this.email = email
    }
    
    method pay(amount: float): boolean {
        print("Paid $" + amount + " via PayPal account: " + email)
        return true
    }
}

// Context
class ShoppingCart {
    private paymentStrategy: PaymentStrategy
    
    method setPaymentStrategy(strategy: PaymentStrategy) {
        this.paymentStrategy = strategy
    }
    
    method checkout(amount: float) {
        paymentStrategy.pay(amount)
    }
}

// Client Code
cart = new ShoppingCart()

// User selects Credit Card
cart.setPaymentStrategy(new CreditCardPayment("4111111111111234"))
cart.checkout(99.99)

// User switches to PayPal
cart.setPaymentStrategy(new PayPalPayment("user@email.com"))
cart.checkout(49.99)
```

---

## Key OOP Concepts Used

| Concept | How It's Used |
|---------|--------------|
| **Interface** | `PaymentStrategy` defines the contract |
| **Polymorphism** | Different strategies respond to the same `pay()` call |
| **Composition** | Context *has a* strategy (not *is a*) |
| **Dependency Injection** | Strategy is injected via `setPaymentStrategy()` |

---

## Comparison: OOP vs Elixir

| Aspect | OOP | Elixir |
|--------|-----|--------|
| **Interface** | `interface PaymentStrategy` | `@behaviour PaymentStrategy` or function signature |
| **Concrete Strategy** | `class CreditCardPayment` | Module with `@behaviour` or a function |
| **Context holds reference** | `private strategy: Strategy` | Pass strategy as function argument |
| **Polymorphism** | Inheritance / Interfaces | Pattern matching / Behaviours |
| **Set strategy at runtime** | `setStrategy(new X())` | `process(data, &strategy_fn/1)` |

---

## When to Apply (Gang of Four)

Use Strategy when:

1. Many related classes differ only in their behavior
2. You need different variants of an algorithm
3. An algorithm uses data that clients shouldn't know about
4. A class defines many behaviors via conditionals — replace with Strategy objects

---

## Related Patterns

- **State**: Similar structure, but intent is different (managing state transitions)
- **Template Method**: Uses inheritance instead of composition
- **Command**: Encapsulates a request as an object (can be seen as a strategy with undo)
