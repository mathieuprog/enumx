# Enumx

Additional utility functions to extend the power of Elixir's Enum module.

## `filter_value/2`

Similar to `filter/2`, but returns the value of the function invocation instead of the element itself.

```elixir
assert Enumx.filter_value([1, 2, 3, 4, 5], &(&1 > 3 && &1 * 2)) == [8, 10]

assert Enumx.filter_value([foo: 1, bar: 2, baz: 3], fn {k, v} -> v > 1 && k end) == [:bar, :baz]

assert Enumx.filter_value(%{foo: 1, bar: 2, baz: 3}, fn {k, v} -> v > 1 && k end) == [:bar, :baz]
```

## `all_equal?/1`

Returns `true` if all elements in `enumerable` are equal.

```elixir
assert Enumx.all_equal?([1, 1])

assert Enumx.all_equal?([foo: 1, foo: 1])
```

## `unique_value!/1`

Returns the single unique element if all elements in enumerable are equal; otherwise, raises an error.

```elixir
assert Enumx.unique_value!([1, 1]) == 1

assert Enumx.unique_value!(%{foo: 1}) == {:foo, 1}

assert Enumx.unique_value!([foo: 1, foo: 1]) == {:foo, 1}

assert_raise ArgumentError, fn ->
  Enumx.unique_value!([]) # raises error: cannot call `unique_value!/1` on an empty list
end

assert_raise RuntimeError, fn ->
  Enumx.unique_value!([1, 2]) # raises error: elements in the list [1, 2] are not equal
end
```

## `with_index_length/2`

Returns tuples of each element, its index, and the total length of the enumerable.

```elixir
assert [{3, 0, :foo}, {3, 1, :bar}, {3, 2, :baz}] ==
          Enumx.with_index_length([:foo, :bar, :baz], fn el, i, length -> {length, i, el} end)

assert [{:foo, 5, 3}, {:bar, 6, 3}, {:baz, 7, 3}] == 
          Enumx.with_index_length([:foo, :bar, :baz], 5)
```

### Installation

Add `enumx` for Elixir as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:enumx, "~> 0.3"}
  ]
end
```

### HexDocs

HexDocs documentation can be found at [https://hexdocs.pm/enumx](https://hexdocs.pm/enumx).
