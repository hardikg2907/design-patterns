# Strategy Pattern - Real World Example: Payment Processing System
# A practical example you might encounter in a production application

# =============================================================================
# PAYMENT STRATEGY BEHAVIOUR
# =============================================================================

defmodule PaymentStrategy do
  @moduledoc "Defines the contract for all payment processors"

  @callback process_payment(amount :: float(), payment_details :: map()) ::
    {:ok, transaction_id :: String.t()} | {:error, reason :: String.t()}

  @callback validate(payment_details :: map()) :: :ok | {:error, reason :: String.t()}

  @callback name() :: String.t()
end

# =============================================================================
# CONCRETE STRATEGIES (Payment Processors)
# =============================================================================

defmodule CreditCardPayment do
  @behaviour PaymentStrategy

  @impl PaymentStrategy
  def name, do: "Credit Card"

  @impl PaymentStrategy
  def validate(%{card_number: card, cvv: cvv, expiry: _expiry}) do
    cond do
      String.length(card) != 16 -> {:error, "Invalid card number length"}
      String.length(cvv) != 3 -> {:error, "Invalid CVV"}
      true -> :ok
    end
  end
  def validate(_), do: {:error, "Missing required card details"}

  @impl PaymentStrategy
  def process_payment(amount, details) do
    case validate(details) do
      :ok ->
        # In real world: call credit card API
        transaction_id = "CC-#{:rand.uniform(999999)}"
        IO.puts("  [CreditCard] Charged $#{amount} to card ending in #{String.slice(details.card_number, -4, 4)}")
        {:ok, transaction_id}
      error -> error
    end
  end
end

defmodule PayPalPayment do
  @behaviour PaymentStrategy

  @impl PaymentStrategy
  def name, do: "PayPal"

  @impl PaymentStrategy
  def validate(%{email: email}) do
    if String.contains?(email, "@"), do: :ok, else: {:error, "Invalid email"}
  end
  def validate(_), do: {:error, "Missing PayPal email"}

  @impl PaymentStrategy
  def process_payment(amount, details) do
    case validate(details) do
      :ok ->
        transaction_id = "PP-#{:rand.uniform(999999)}"
        IO.puts("  [PayPal] Charged $#{amount} to #{details.email}")
        {:ok, transaction_id}
      error -> error
    end
  end
end

defmodule CryptoPayment do
  @behaviour PaymentStrategy

  @impl PaymentStrategy
  def name, do: "Cryptocurrency"

  @impl PaymentStrategy
  def validate(%{wallet_address: addr}) do
    if String.length(addr) > 20, do: :ok, else: {:error, "Invalid wallet address"}
  end
  def validate(_), do: {:error, "Missing wallet address"}

  @impl PaymentStrategy
  def process_payment(amount, details) do
    case validate(details) do
      :ok ->
        transaction_id = "CRYPTO-#{:rand.uniform(999999)}"
        IO.puts("  [Crypto] Transferred $#{amount} worth to #{String.slice(details.wallet_address, 0, 10)}...")
        {:ok, transaction_id}
      error -> error
    end
  end
end

# =============================================================================
# CONTEXT: Payment Processor
# =============================================================================

defmodule PaymentProcessor do
  @moduledoc "Context that uses payment strategies"

  def checkout(cart_total, payment_strategy, payment_details) do
    IO.puts("\n📦 Processing order for $#{cart_total}...")
    IO.puts("💳 Payment method: #{payment_strategy.name()}")

    case payment_strategy.process_payment(cart_total, payment_details) do
      {:ok, transaction_id} ->
        IO.puts("✅ Payment successful! Transaction ID: #{transaction_id}")
        {:ok, transaction_id}
      {:error, reason} ->
        IO.puts("❌ Payment failed: #{reason}")
        {:error, reason}
    end
  end
end

# =============================================================================
# DEMONSTRATION
# =============================================================================

IO.puts("=== Real World Example: E-commerce Payment System ===")

# Customer 1: Pays with Credit Card
PaymentProcessor.checkout(
  99.99,
  CreditCardPayment,
  %{card_number: "4111111111111234", cvv: "123", expiry: "12/25"}
)

# Customer 2: Pays with PayPal
PaymentProcessor.checkout(
  49.99,
  PayPalPayment,
  %{email: "customer@example.com"}
)

# Customer 3: Pays with Crypto
PaymentProcessor.checkout(
  199.99,
  CryptoPayment,
  %{wallet_address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"}
)

# Failed payment example
IO.puts("\n--- Failed Payment Example ---")
PaymentProcessor.checkout(
  25.00,
  CreditCardPayment,
  %{card_number: "1234", cvv: "12", expiry: "12/25"}  # Invalid card
)

IO.puts("\n=== KEY TAKEAWAYS ===")
IO.puts("""
1. Each payment method implements the same PaymentStrategy behaviour
2. PaymentProcessor doesn't know HOW payments are processed - it just calls the strategy
3. Adding a new payment method (e.g., Apple Pay) requires:
   - Creating a new module with @behaviour PaymentStrategy
   - No changes to PaymentProcessor!
4. This follows Open/Closed Principle: open for extension, closed for modification
""")
