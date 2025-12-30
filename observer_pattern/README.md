# Observer Pattern (Publish/Subscribe)

## What is the Observer Pattern?

The **Observer Pattern** defines a **one-to-many dependency** between objects. When one object (the **Subject/Observable**) changes state, all its dependents (the **Observers**) are notified and updated automatically.

Think of it like a **YouTube subscription**:
- 📺 **Subject** = YouTube Channel
- 👥 **Observers** = Subscribers
- When a new video is uploaded, **all subscribers get notified**

---

## What Problem Does It Solve?

1. **Decoupling** - Publishers don't need to know who their subscribers are
2. **Dynamic relationships** - Observers can subscribe/unsubscribe at runtime
3. **Broadcast communication** - One update notifies many listeners
4. **Event-driven architecture** - React to state changes without polling

---

## When Should You Use It?

✅ When changes to one object require changing others, and you don't know how many objects need to change  
✅ When an object should notify other objects without knowing who they are  
✅ When you want loose coupling between interacting objects  
✅ For event handling systems, GUIs, real-time feeds, logging systems

---

## Key Participants

| Component | Role | Elixir Equivalent |
|-----------|------|-------------------|
| **Subject/Publisher** | Maintains a list of observers, sends notifications | `GenServer` / `Registry` |
| **Observer/Subscriber** | Receives updates from the subject | Process / `GenServer` |
| **Concrete Subject** | Stores state, notifies observers on state change | Module implementing the subject |
| **Concrete Observer** | Implements the update logic | Module implementing `handle_info` |

---

## Elixir's Approach

In Elixir, the Observer pattern is naturally implemented using:

1. **Message Passing** - Processes communicate via messages (not method calls)
2. **GenServer** - For stateful observers and subjects
3. **Registry** - Built-in for local pub/sub functionality
4. **Phoenix.PubSub** - For distributed pub/sub across nodes

The functional nature of Elixir makes this pattern feel very native!

---

## Files in This Folder

| File | Description |
|------|-------------|
| `OOP_REFERENCE.md` | Traditional OOP implementation for reference |
| `basic_example.exs` | Simple interactive example (start here!) |
| `generalized_example.exs` | Reusable/abstract implementation |
| `real_world_example.exs` | Practical use case |

---

## Quick Diagram

```
┌─────────────────┐
│     Subject     │
│   (Publisher)   │
└────────┬────────┘
         │
         │ notify()
         ▼
┌────────┴────────┐
│                 │
▼                 ▼
┌──────────┐  ┌──────────┐
│Observer 1│  │Observer 2│  ...
│(Subscriber)│  │(Subscriber)│
└──────────┘  └──────────┘
```

---

## Learning Progress

- [x] Read this README
- [x] Understand OOP reference
- [x] Complete basic example
- [x] Review generalized example
- [x] Implement real-world example
