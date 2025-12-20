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
  Enumx.unique_value!([]) # raises: cannot get unique value from empty enumerable
end

assert_raise ArgumentError, fn ->
  Enumx.unique_value!([1, 2]) # raises: elements in enumerable are not equal
end
```

## `one!/1`

Returns the only element if the enumerable contains exactly one element; otherwise, raises. Similar to `Repo.one!/1` in Ecto.

```elixir
assert Enumx.one!([42]) == 42

assert Enumx.one!(%{foo: 1}) == {:foo, 1}

assert Enumx.one!(1..1) == 1

assert_raise ArgumentError, fn ->
  Enumx.one!([]) # raises: expected single element, got none
end

assert_raise ArgumentError, fn ->
  Enumx.one!([1, 2, 3]) # raises: expected single element, got 3
end
```

## `is_plain_map/1`

Determines if the given term is a plain map (not a struct). It can be as a guard clause.

```elixir
assert Enumx.is_plain_map(%{}) == true
assert Enumx.is_plain_map(%MyStruct{}) == false
assert Enumx.is_plain_map(1..5) == false
```

## `shift_left_by_index/2` and `shift_left_by_index!/2`

Shifts the element at the given index one position to the left.

```elixir
assert Enumx.shift_left_by_index([1, 2, 3], 1) == {:ok, [2, 1, 3], :shifted}
```

## `shift_right_by_index/2` and `shift_right_by_index!/2`

Shifts the element at the given index one position to the right.

```elixir
assert Enumx.shift_right_by_index([1, 2, 3], 1) == {:ok, [1, 3, 2], :shifted}
```

## `shift_first_match_left/3` and `shift_first_match_left!/3`

Shifts the first element that matches the comparison function one position to the left.

```elixir
assert Enumx.shift_first_match_left([1, 2, 3], 2, &(&1 == &2)) == {:ok, [2, 1, 3], :shifted}
```

## `shift_first_match_right/3` and `shift_first_match_right!/3`

Shifts the first element that matches the comparison function one position to the right.

```elixir
assert Enumx.shift_first_match_right([1, 2, 3], 2, &(&1 == &2)) == {:ok, [1, 3, 2], :shifted}
```

## `swap/3` and `swap!/3`

Swaps the elements at the given indices.

```elixir
assert Enumx.swap([1, 2, 3], 0, 2) == {:ok, [3, 2, 1], :swapped}
```

## `join/3`

Joins the elements of a list into a string, using the specified delimiter between elements and a different delimiter before the last element. This function is useful for formatting lists of items in natural language.

```elixir
assert "foo, bar and baz" == Enumx.join(["foo", "bar", "baz"], ", ", " and ")
assert "foo and bar" == Enumx.join(["foo", "bar"], ", ", " and ")
assert "foo" == Enumx.join(["foo"], ", ", " and ")
assert "" == Enumx.join([], ", ", " and ")
```

## `with_index_length/2`

Returns tuples of each element, its index, and the total length of the enumerable.

```elixir
assert [{:foo, 0, 3}, {:bar, 1, 3}, {:baz, 2, 3}] ==
          Enumx.with_index_length([:foo, :bar, :baz])

assert [{:foo, 5, 3}, {:bar, 6, 3}, {:baz, 7, 3}] ==
          Enumx.with_index_length([:foo, :bar, :baz], 5)

assert [{3, 0, :foo}, {3, 1, :bar}, {3, 2, :baz}] ==
          Enumx.with_index_length([:foo, :bar, :baz], fn el, i, length -> {length, i, el} end)
```

## `with_value/2`

Returns each element and the result of a function taking the element. A static value can also be added to each element.

```elixir
assert [{"foo", "oof"}, {"bar", "rab"}, {"baz", "zab"}] ==
          Enumx.with_value(["foo", "bar", "baz"], &String.reverse/1)
```

This function adds semantics and reduces special characters, ideal for keeping code clear when used in templates, compared with the Enum.map equivalent:

```elixir
Enumx.with_value(["foo", "bar", "baz"], &String.reverse/1)

Enum.map(["foo", "bar", "baz"], &{&1, String.reverse(&1)})
```

## `decimal_sum/1`

Sums all Decimal values in the enumerable. Requires the optional `decimal` dependency.

```elixir
assert Decimal.equal?(
         Enumx.decimal_sum([Decimal.new("1.5"), Decimal.new("2.5"), Decimal.new("3.0")]),
         Decimal.new("7.0")
       )

assert Decimal.equal?(Enumx.decimal_sum([]), Decimal.new("0"))
```

## `decimal_sum_by/2`

Maps and sums Decimal values in the enumerable. Requires the optional `decimal` dependency.

```elixir
items = [
  %{price: Decimal.new("10.50")},
  %{price: Decimal.new("20.25")},
  %{price: Decimal.new("5.25")}
]

assert Decimal.equal?(
         Enumx.decimal_sum_by(items, & &1.price),
         Decimal.new("36.00")
       )
```

### Installation

Add `enumx` for Elixir as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:enumx, "~> 0.9"}
  ]
end
```

### HexDocs

HexDocs documentation can be found at [https://hexdocs.pm/enumx](https://hexdocs.pm/enumx).
