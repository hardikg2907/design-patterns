# Observer Pattern — OOP Reference

This document explains the Observer pattern in its traditional **Object-Oriented Programming** format, so you can understand the original design before seeing the Elixir adaptation.

---

## UML Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │             <<interface>> Subject                        │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ + attach(observer: Observer): void                       │   │
│  │ + detach(observer: Observer): void                       │   │
│  │ + notify(): void                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            ▲                                   │
│                            │ implements                         │
│  ┌─────────────────────────┴───────────────────────────────┐   │
│  │               ConcreteSubject                            │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ - observers: List<Observer>                              │   │
│  │ - state: any                                             │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ + attach(observer): void                                 │   │
│  │ + detach(observer): void                                 │   │
│  │ + notify(): void                                         │   │
│  │ + getState(): any                                        │   │
│  │ + setState(state): void                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            │ notifies                           │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │             <<interface>> Observer                       │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ + update(subject: Subject): void                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            ▲                                    │
│                            │ implements                         │
│         ┌──────────────────┼──────────────────┐                │
│         │                  │                  │                 │
│  ┌──────┴──────┐   ┌───────┴──────┐   ┌──────┴───────┐        │
│  │ ObserverA   │   │  ObserverB   │   │  ObserverC   │        │
│  ├─────────────┤   ├──────────────┤   ├──────────────┤        │
│  │ +update()   │   │ +update()    │   │ +update()    │        │
│  └─────────────┘   └──────────────┘   └──────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Participants

| Participant | Role |
|-------------|------|
| **Subject** (Interface) | Declares interface for attaching/detaching/notifying observers |
| **ConcreteSubject** | Stores state and notifies observers when state changes |
| **Observer** (Interface) | Declares the update interface for receiving notifications |
| **ConcreteObserver** | Implements the update method to react to subject changes |

---

## Pseudocode (OOP Style)

```plaintext
// The Observer Interface
interface Observer {
    method update(channel: String, videoTitle: String): void
}

// The Subject Interface
interface Subject {
    method attach(observer: Observer): void
    method detach(observer: Observer): void
    method notify(): void
}

// Concrete Subject
class YouTubeChannel implements Subject {
    private observers: List<Observer>
    private channelName: String
    private latestVideo: String
    
    constructor(name: String) {
        this.channelName = name
        this.observers = new List()
    }
    
    method attach(observer: Observer): void {
        observers.add(observer)
        print("New subscriber added to " + channelName)
    }
    
    method detach(observer: Observer): void {
        observers.remove(observer)
        print("Subscriber removed from " + channelName)
    }
    
    method notify(): void {
        for each observer in observers {
            observer.update(channelName, latestVideo)
        }
    }
    
    method uploadVideo(title: String): void {
        this.latestVideo = title
        print(channelName + " uploaded: " + title)
        notify()  // Notify all observers when state changes!
    }
}

// Concrete Observer
class Subscriber implements Observer {
    private name: String
    
    constructor(name: String) {
        this.name = name
    }
    
    method update(channel: String, videoTitle: String): void {
        print(name + " received: New video '" + videoTitle + "' from " + channel)
    }
}

// Client Code
channel = new YouTubeChannel("ElixirLearning")

alice = new Subscriber("Alice")
bob = new Subscriber("Bob")
charlie = new Subscriber("Charlie")

// Subscribe
channel.attach(alice)
channel.attach(bob)
channel.attach(charlie)

// Upload triggers notification to ALL subscribers
channel.uploadVideo("Observer Pattern Explained")

// Bob unsubscribes
channel.detach(bob)

// Only Alice and Charlie get notified
channel.uploadVideo("Strategy Pattern Deep Dive")
```

---

## Key OOP Concepts Used

| Concept | How It's Used |
|---------|--------------|
| **Interface** | `Subject` and `Observer` define contracts |
| **Polymorphism** | Different observers react differently to `update()` |
| **Composition** | Subject *has* observers (not *is a*) |
| **Loose Coupling** | Subject doesn't know concrete observer types |

---

## Comparison: OOP vs Elixir

| Aspect | OOP | Elixir |
|--------|-----|--------|
| **Subject Interface** | `interface Subject` | GenServer / Registry |
| **Observer Interface** | `interface Observer` | Process with `receive` block |
| **Store observers** | `List<Observer>` field | List of PIDs in GenServer state |
| **Attach/Detach** | `attach()` / `detach()` methods | `subscribe()` / `unsubscribe()` calls |
| **Notify** | Loop calling `observer.update()` | `send(pid, message)` to each PID |
| **Polymorphism** | Interface implementation | Pattern matching on messages |

---

## When to Apply (Gang of Four)

Use Observer when:

1. A change to one object requires changing others, and you don't know how many
2. An object should notify others without knowing who they are
3. You want loose coupling between the subject and its observers
4. You need to implement distributed event handling systems

---

## Related Patterns

- **Mediator**: Centralizes complex communications between objects
- **Singleton**: Often used to make the subject globally accessible
- **Command**: Can be combined with Observer for undo/redo functionality
