# ============================================================
# DECORATOR PATTERN - Real World Example: HTTP Client Middleware
# ============================================================
#
# This example shows how the Decorator pattern is used in real-world
# applications. HTTP clients often use middleware/decorator chains
# to add functionality like:
# - Logging
# - Authentication
# - Caching
# - Retry logic
# - Rate limiting
# - Metrics collection
#
# This is EXACTLY how libraries like Tesla (Elixir HTTP client) work!

defmodule HTTPRequest do
  @moduledoc "Represents an HTTP request"

  defstruct [
    :method,
    :url,
    :headers,
    :body,
    :opts
  ]

  def new(method, url, opts \\ []) do
    %__MODULE__{
      method: method,
      url: url,
      headers: Keyword.get(opts, :headers, []),
      body: Keyword.get(opts, :body, nil),
      opts: opts
    }
  end
end

defmodule HTTPResponse do
  @moduledoc "Represents an HTTP response"

  defstruct [
    :status,
    :headers,
    :body,
    :request,
    :metadata
  ]
end

# ============================================================
# THE MIDDLEWARE BEHAVIOUR (Decorator Interface)
# ============================================================

defmodule HTTPMiddleware do
  @moduledoc """
  Behaviour for HTTP middleware (decorators).

  Each middleware receives the request, can modify it, calls the next
  middleware in the chain, and can modify the response.

  This is the Decorator pattern in action!
  """

  @callback call(
              request :: HTTPRequest.t(),
              next :: (HTTPRequest.t() -> HTTPResponse.t())
            ) :: HTTPResponse.t()
end

# ============================================================
# MIDDLEWARE IMPLEMENTATIONS (Concrete Decorators)
# ============================================================

defmodule Middleware.Logger do
  @behaviour HTTPMiddleware
  @moduledoc "Logs request and response details"

  @impl true
  def call(request, next) do
    IO.puts("\n📤 [Logger] Request: #{request.method} #{request.url}")

    start_time = System.monotonic_time(:millisecond)
    response = next.(request)
    duration = System.monotonic_time(:millisecond) - start_time

    IO.puts("📥 [Logger] Response: #{response.status} (#{duration}ms)")
    response
  end
end

defmodule Middleware.Auth do
  @behaviour HTTPMiddleware
  @moduledoc "Adds authentication headers"

  @impl true
  def call(request, next) do
    IO.puts("🔐 [Auth] Adding authentication header")

    # Simulate getting a token
    token = "Bearer abc123xyz"

    authenticated_request = %{
      request
      | headers: [{"Authorization", token} | request.headers]
    }

    next.(authenticated_request)
  end
end

defmodule Middleware.Retry do
  @behaviour HTTPMiddleware
  @moduledoc "Retries failed requests"

  @max_retries 3

  @impl true
  def call(request, next) do
    do_call(request, next, 1)
  end

  defp do_call(request, next, attempt) when attempt <= @max_retries do
    response = next.(request)

    if response.status >= 500 and attempt < @max_retries do
      IO.puts("🔄 [Retry] Attempt #{attempt} failed, retrying...")
      Process.sleep(100 * attempt)  # Exponential backoff
      do_call(request, next, attempt + 1)
    else
      response
    end
  end
end

defmodule Middleware.Cache do
  @behaviour HTTPMiddleware
  @moduledoc "Caches GET responses (simulated)"

  # In real app, you'd use ETS or Redis
  @cache %{
    "https://api.example.com/cached" => %HTTPResponse{
      status: 200,
      body: ~s({"cached": true, "data": "from cache!"}),
      headers: [{"X-Cache", "HIT"}],
      metadata: %{}
    }
  }

  @impl true
  def call(request, next) do
    if request.method == :get and Map.has_key?(@cache, request.url) do
      IO.puts("💾 [Cache] HIT - Returning cached response")
      Map.get(@cache, request.url)
    else
      IO.puts("💾 [Cache] MISS - Fetching from server")
      response = next.(request)
      # In real app, store response in cache here
      response
    end
  end
end

defmodule Middleware.RateLimiter do
  @behaviour HTTPMiddleware
  @moduledoc "Enforces rate limits"

  # Simulate rate limit tracking (in real app, use ETS/Redis)
  @requests_per_second 10

  @impl true
  def call(request, next) do
    # Simplified rate limiting check
    if :rand.uniform(10) > 8 do
      IO.puts("⛔ [RateLimiter] Rate limit exceeded!")
      %HTTPResponse{
        status: 429,
        body: ~s({"error": "Too Many Requests"}),
        headers: [{"Retry-After", "1"}],
        request: request,
        metadata: %{rate_limited: true}
      }
    else
      IO.puts("✅ [RateLimiter] Request allowed")
      next.(request)
    end
  end
end

defmodule Middleware.Metrics do
  @behaviour HTTPMiddleware
  @moduledoc "Collects metrics about requests"

  @impl true
  def call(request, next) do
    start_time = System.monotonic_time(:microsecond)

    response = next.(request)

    duration = System.monotonic_time(:microsecond) - start_time
    IO.puts("📊 [Metrics] #{request.method} #{request.url} - #{response.status} - #{duration}μs")

    # Add metrics to response metadata
    %{
      response
      | metadata: Map.put(response.metadata || %{}, :duration_us, duration)
    }
  end
end

# ============================================================
# HTTP CLIENT WITH MIDDLEWARE STACK
# ============================================================

defmodule HTTPClient do
  @moduledoc """
  HTTP Client that uses middleware stack (decorators).

  The client composes multiple middleware together, where each
  middleware decorates the final request handler.
  """

  @doc """
  Build a middleware stack. Order matters!
  First middleware in list wraps all others.
  """
  def build_stack(middlewares, base_handler) do
    Enum.reduce(Enum.reverse(middlewares), base_handler, fn middleware, next ->
      fn request -> middleware.call(request, next) end
    end)
  end

  @doc "The base handler that actually 'makes' the request"
  def base_handler(request) do
    # Simulate network request
    Process.sleep(50)

    # Simulate different responses based on URL
    cond do
      String.contains?(request.url, "error") ->
        %HTTPResponse{
          status: 500,
          body: ~s({"error": "Internal Server Error"}),
          headers: [],
          request: request,
          metadata: %{}
        }

      String.contains?(request.url, "users") ->
        %HTTPResponse{
          status: 200,
          body: ~s({"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}),
          headers: [{"Content-Type", "application/json"}],
          request: request,
          metadata: %{}
        }

      true ->
        %HTTPResponse{
          status: 200,
          body: ~s({"message": "Success!"}),
          headers: [{"Content-Type", "application/json"}],
          request: request,
          metadata: %{}
        }
    end
  end

  @doc "Convenience function to make a request with default middleware"
  def request(method, url, opts \\ []) do
    # Define our middleware stack - DECORATORS!
    middlewares = [
      Middleware.Metrics,      # Outermost - tracks total time
      Middleware.Logger,       # Log requests
      Middleware.RateLimiter,  # Check rate limits early
      Middleware.Cache,        # Check cache before auth
      Middleware.Auth,         # Add auth headers
      Middleware.Retry         # Retry failed requests
    ]

    handler = build_stack(middlewares, &base_handler/1)
    request = HTTPRequest.new(method, url, opts)

    handler.(request)
  end

  def get(url, opts \\ []), do: request(:get, url, opts)
  def post(url, opts \\ []), do: request(:post, url, opts)
end

# ============================================================
# DEMO
# ============================================================

IO.puts(String.duplicate("=", 70))
IO.puts("🌐 HTTP CLIENT WITH MIDDLEWARE (Decorator Pattern)")
IO.puts(String.duplicate("=", 70))

IO.puts("\n" <> String.duplicate("-", 70))
IO.puts("📍 Request 1: Normal GET request")
IO.puts(String.duplicate("-", 70))
response1 = HTTPClient.get("https://api.example.com/users")
IO.puts("\n📦 Response body: #{response1.body}")

IO.puts("\n" <> String.duplicate("-", 70))
IO.puts("📍 Request 2: Cached endpoint")
IO.puts(String.duplicate("-", 70))
response2 = HTTPClient.get("https://api.example.com/cached")
IO.puts("\n📦 Response body: #{response2.body}")

IO.puts("\n" <> String.duplicate("-", 70))
IO.puts("📍 Request 3: Error endpoint (will trigger retry)")
IO.puts(String.duplicate("-", 70))
response3 = HTTPClient.get("https://api.example.com/error")
IO.puts("\n📦 Response status: #{response3.status}")

# ============================================================
# WHY THIS PATTERN MATTERS
# ============================================================

IO.puts("\n" <> String.duplicate("=", 70))
IO.puts("🔑 WHY THE DECORATOR PATTERN MATTERS HERE")
IO.puts(String.duplicate("=", 70))

IO.puts("""

1. MODULARITY
   Each middleware (decorator) handles ONE concern.
   Easy to understand, test, and maintain.

2. FLEXIBILITY
   Add/remove/reorder middleware without changing other code.
   Different clients can have different middleware stacks.

3. REUSABILITY
   Middleware can be reused across different clients/projects.
   Write once, use everywhere!

4. REAL LIBRARIES USE THIS
   - Tesla (Elixir HTTP client) - uses middleware
   - Plug (Phoenix foundation) - uses plugs (decorators!)
   - Axios (JavaScript) - uses interceptors

5. ELIXIR ADVANTAGE
   The pipe operator makes middleware chains beautiful:

   request
   |> add_auth()
   |> check_cache()
   |> log_request()
   |> make_request()
   |> log_response()
   |> parse_body()

COMPARE TO OOP DECORATOR:

   new LoggingDecorator(
     new CacheDecorator(
       new AuthDecorator(
         new RetryDecorator(
           new BaseHttpClient()
         )
       )
     )
   ).request(url)

   🤮 vs 😍
""")
