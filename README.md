# Enumx

Additional utility functions to extend the power of Elixir's Enum module.

## `filter_value/2`

Similar to `filter/2`, but returns the value of the function invocation instead of the element itself.

```elixir
import Enumx, only: [filter_value: 2]

assert filter_value([1, 2, 3, 4, 5], &(&1 > 3 && &1 * 2)) == [8, 10]

assert filter_value([foo: 1, bar: 2, baz: 3], fn {k, v} -> v > 1 && k end) == [:bar, :baz]

assert filter_value(%{foo: 1, bar: 2, baz: 3}, fn {k, v} -> v > 1 && k end) == [:bar, :baz]
```

## `all_equal?/1`

Returns `true` if all elements in `enumerable` are equal.

```elixir
import Enumx, only: [all_equal?: 1]

assert all_equal?([1, 1])

assert all_equal?([foo: 1, foo: 1])
```

## `unique_value!/1`

Returns `true` if all elements in `enumerable` are equal.

```elixir
import Enumx, only: [unique_value!: 1]

assert unique_value!([1, 1]) == 1

assert unique_value!(%{foo: 1}) == {:foo, 1}

assert unique_value!([foo: 1, foo: 1]) == {:foo, 1}

assert_raise ArgumentError, fn ->
  unique_value!([]) # raises error: cannot call `unique_value!/1` on an empty list
end
```

### Installation

Add `enumx` for Elixir as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:enumx, "~> 0.1.0"}
  ]
end
```

### HexDocs

HexDocs documentation can be found at [https://hexdocs.pm/enumx](https://hexdocs.pm/enumx).
