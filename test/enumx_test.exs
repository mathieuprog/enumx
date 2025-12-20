defmodule EnumxTest do
  use ExUnit.Case

  import Enumx

  test "filter_value/2" do
    assert filter_value([1, 2, 3, 4, 5, 0, 8], &(&1 > 3 && &1 * 2)) == [8, 10, 16]
    assert filter_value([1, 2, 3, 4, 5, 0, 8], &(&1 > 10 && &1 * 2)) == []
    assert filter_value([], &(&1 > 10 && &1 * 2)) == []
    assert filter_value(%{foo: 1, bar: 2, baz: 3}, fn {_k, v} -> v > 1 && v end) == [2, 3]
    assert filter_value([foo: 1, bar: 2, baz: 3], fn {k, v} -> v > 1 && k end) == [:bar, :baz]
  end

  test "all_equal?/1" do
    assert all_equal?([])
    assert all_equal?([1, 1])
    refute all_equal?([1, 2])
    refute all_equal?(%{foo: 1, bar: 1})
    assert all_equal?(foo: 1, foo: 1)
    refute all_equal?(foo: 1, foo: 2)
    refute all_equal?(foo: 1, bar: 1)

    # Ranges and other enumerables
    assert all_equal?(1..1)
    refute all_equal?(1..5)
    assert all_equal?(Stream.map([1, 1, 1], & &1))
    refute all_equal?(Stream.map([1, 2, 3], & &1))
  end

  test "with_index_length/2" do
    assert [{0, :foo}, {1, :bar}, {2, :baz}] ==
             Enum.with_index([:foo, :bar, :baz], fn el, i -> {i, el} end)

    assert [{0, {:foo, 10}}, {1, {:bar, 11}}, {2, {:baz, 12}}] ==
             Enum.with_index(%{foo: 10, bar: 11, baz: 12}, fn el, i -> {i, el} end)

    assert [{3, 0, :foo}, {3, 1, :bar}, {3, 2, :baz}] ==
             with_index_length([:foo, :bar, :baz], fn el, i, length -> {length, i, el} end)

    assert [{3, 0, {:foo, 10}}, {3, 1, {:bar, 11}}, {3, 2, {:baz, 12}}] ==
             with_index_length(%{foo: 10, bar: 11, baz: 12}, fn el, i, length ->
               {length, i, el}
             end)

    assert [{:foo, 5}, {:bar, 6}, {:baz, 7}] == Enum.with_index([:foo, :bar, :baz], 5)
    assert [{:foo, 5, 3}, {:bar, 6, 3}, {:baz, 7, 3}] == with_index_length([:foo, :bar, :baz], 5)
  end

  test "with_value/2" do
    assert [{"foo", "oof"}, {"bar", "rab"}, {"baz", "zab"}] ==
             Enumx.with_value(["foo", "bar", "baz"], &String.reverse/1)

    assert [{"foo", "oof"}, {"bar", "rab"}, {"baz", "zab"}] ==
             Enum.map(["foo", "bar", "baz"], &{&1, String.reverse(&1)})
  end

  test "unique_value!/1" do
    assert_raise ArgumentError, ~r/empty enumerable/, fn ->
      unique_value!([])
    end

    assert_raise ArgumentError, ~r/empty enumerable/, fn ->
      unique_value!(%{})
    end

    assert_raise ArgumentError, ~r/not equal/, fn ->
      unique_value!(1..5)
    end

    assert_raise ArgumentError, ~r/not equal/, fn ->
      unique_value!([1, 1, 2, 1])
    end

    assert_raise ArgumentError, ~r/not equal/, fn ->
      unique_value!(foo: 1, bar: 1)
    end

    assert_raise ArgumentError, ~r/not equal/, fn ->
      unique_value!(foo: 1, foo: 2)
    end

    assert_raise ArgumentError, ~r/not equal/, fn ->
      unique_value!(%{foo: 1, bar: 1})
    end

    assert unique_value!([1, 1]) == 1
    assert unique_value!(%{foo: 1}) == {:foo, 1}
    assert unique_value!(foo: 1, foo: 1) == {:foo, 1}

    # Ranges and other enumerables
    assert unique_value!(1..1) == 1
    assert unique_value!(Stream.map([42, 42], & &1)) == 42
  end

  test "one!/1" do
    # Empty enumerables raise
    assert_raise ArgumentError, ~r/got none/, fn ->
      one!([])
    end

    assert_raise ArgumentError, ~r/got none/, fn ->
      one!(%{})
    end

    # Single element returns the element
    assert one!([42]) == 42
    assert one!([:foo]) == :foo
    assert one!([%{id: 1}]) == %{id: 1}

    # Single element map returns {key, value} tuple
    assert one!(%{foo: 1}) == {:foo, 1}

    # Keyword list with single element
    assert one!(foo: 42) == {:foo, 42}

    # Range with single element
    assert one!(1..1) == 1

    # Multiple elements raise
    assert_raise ArgumentError, ~r/expected single element, got 2/, fn ->
      one!([1, 2])
    end

    assert_raise ArgumentError, ~r/expected single element, got 3/, fn ->
      one!([1, 2, 3])
    end

    assert_raise ArgumentError, ~r/expected single element, got 2/, fn ->
      one!(%{foo: 1, bar: 2})
    end

    assert_raise ArgumentError, ~r/expected single element, got multiple/, fn ->
      one!(1..5)
    end

    # Keyword list with multiple elements
    assert_raise ArgumentError, ~r/expected single element, got 2/, fn ->
      one!(foo: 1, bar: 2)
    end
  end

  test "find_one!/2" do
    # Single match returns element
    assert find_one!([1, 2, 3], &(&1 == 2)) == 2
    assert find_one!([%{id: 1}, %{id: 2}], &(&1.id == 2)) == %{id: 2}

    # Works with ranges and streams
    assert find_one!(1..10, &(&1 == 5)) == 5
    assert find_one!(Stream.map(1..5, & &1), &(&1 == 3)) == 3

    # Works with maps (finds matching {key, value} tuple)
    assert find_one!(%{a: 1, b: 2, c: 3}, fn {_k, v} -> v == 2 end) == {:b, 2}

    # No match raises
    assert_raise ArgumentError, ~r/no element matched/, fn ->
      find_one!([1, 2, 3], &(&1 > 10))
    end

    # Multiple matches raises
    assert_raise ArgumentError, ~r/expected single match, got multiple/, fn ->
      find_one!([1, 2, 3, 4], &(&1 > 1))
    end

    # Empty enumerable raises
    assert_raise ArgumentError, ~r/no element matched/, fn ->
      find_one!([], fn _ -> true end)
    end
  end

  test "shift_first_match_left/3 and shift_first_match_right/3" do
    entities = [%{id: 4}, %{id: 2}, %{id: 7}]
    entities_kw = [id: 4, id: 2, id: 7]

    assert {:error, [], :element_not_found} ==
             shift_first_match_left([], %{id: 2}, &(&1.id == &2.id))

    assert_raise ArgumentError, ~r/not supported on maps/, fn ->
      shift_first_match_left(%{}, {:id, 2}, &(&1.id == &2.id))
    end

    assert_raise ArgumentError, ~r/not supported on MapSet/, fn ->
      shift_first_match_left(MapSet.new([1, 2]), 2)
    end

    assert {:ok, [%{id: 2}, %{id: 4}, %{id: 7}], :shifted} ==
             shift_first_match_left(entities, %{id: 2}, &(&1.id == &2.id))

    assert {:ok, [%{id: 4}, %{id: 2}, %{id: 7}], :not_shifted} ==
             shift_first_match_left(entities, %{id: 4}, &(&1.id == &2.id))

    assert {:ok, [%{id: 4}, %{id: 7}, %{id: 2}], :shifted} ==
             shift_first_match_left(entities, %{id: 7}, &(&1.id == &2.id))

    assert {:error, [%{id: 4}, %{id: 2}, %{id: 7}], :element_not_found} ==
             shift_first_match_left(entities, %{id: 8}, &(&1.id == &2.id))

    assert {:ok, [id: 4, id: 7, id: 2], :shifted} ==
             shift_first_match_left(entities_kw, {:id, 7}, &(elem(&1, 1) == elem(&2, 1)))

    assert {:error, [id: 4, id: 2, id: 7], :element_not_found} ==
             shift_first_match_left(entities_kw, {:id, 8}, &(elem(&1, 1) == elem(&2, 1)))

    assert {:ok, [2, 1, 3, 4, 5], :shifted} ==
             shift_first_match_left(1..5, 2)

    assert {:error, [1, 2, 3, 4, 5], :element_not_found} ==
             shift_first_match_left(1..5, 8)

    assert_raise ArgumentError, ~r/not found/, fn ->
      shift_first_match_left!(entities, %{id: 8}, &(&1.id == &2.id))
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_first_match_left!(entities, %{id: 4}, &(&1.id == &2.id))

    assert {:error, [], :element_not_found} ==
             shift_first_match_right([], %{id: 2}, &(&1.id == &2.id))

    assert_raise ArgumentError, ~r/not supported on maps/, fn ->
      shift_first_match_right(%{}, {:id, 2}, &(&1.id == &2.id))
    end

    assert_raise ArgumentError, ~r/not supported on MapSet/, fn ->
      shift_first_match_right(MapSet.new([1, 2]), 2)
    end

    assert {:ok, [%{id: 4}, %{id: 7}, %{id: 2}], :shifted} ==
             shift_first_match_right(entities, %{id: 2}, &(&1.id == &2.id))

    assert {:ok, [%{id: 2}, %{id: 4}, %{id: 7}], :shifted} ==
             shift_first_match_right(entities, %{id: 4}, &(&1.id == &2.id))

    assert {:ok, [%{id: 4}, %{id: 2}, %{id: 7}], :not_shifted} ==
             shift_first_match_right(entities, %{id: 7}, &(&1.id == &2.id))

    assert {:error, [%{id: 4}, %{id: 2}, %{id: 7}], :element_not_found} ==
             shift_first_match_right(entities, %{id: 8}, &(&1.id == &2.id))

    assert {:ok, [id: 2, id: 4, id: 7], :shifted} ==
             shift_first_match_right(entities_kw, {:id, 4}, &(elem(&1, 1) == elem(&2, 1)))

    assert {:error, [id: 4, id: 2, id: 7], :element_not_found} ==
             shift_first_match_right(entities_kw, {:id, 8}, &(elem(&1, 1) == elem(&2, 1)))

    assert {:error, [1, 2, 3, 4, 5], :element_not_found} ==
             shift_first_match_right(1..5, 8)

    assert_raise ArgumentError, ~r/not found/, fn ->
      shift_first_match_right!(entities, %{id: 8}, &(&1.id == &2.id))
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_first_match_right!(entities, %{id: 7}, &(&1.id == &2.id))
  end

  test "shift_left_by_index/2 and shift_right_by_index/2" do
    entities = [%{id: 4}, %{id: 2}, %{id: 7}]

    assert {:error, [], :index_out_of_bounds} ==
             shift_left_by_index([], 0)

    assert {:error, [], :index_out_of_bounds} ==
             shift_left_by_index([], 5)

    assert_raise ArgumentError, ~r/not supported on maps/, fn ->
      shift_left_by_index(%{}, 5)
    end

    assert_raise ArgumentError, ~r/not supported on MapSet/, fn ->
      shift_left_by_index(MapSet.new([1, 2]), 0)
    end

    assert {:ok, [%{id: 2}], :not_shifted} ==
             shift_left_by_index([%{id: 2}], 0)

    assert {:error, [%{id: 2}], :index_out_of_bounds} ==
             shift_left_by_index([%{id: 2}], 5)

    assert {:ok, [%{id: 2}, %{id: 4}, %{id: 7}], :shifted} ==
             shift_left_by_index(entities, 1)

    assert {:ok, [%{id: 4}, %{id: 2}, %{id: 7}], :not_shifted} ==
             shift_left_by_index(entities, 0)

    assert {:ok, [%{id: 4}, %{id: 7}, %{id: 2}], :shifted} ==
             shift_left_by_index(entities, 2)

    assert {:error, [%{id: 4}, %{id: 2}, %{id: 7}], :index_out_of_bounds} ==
             shift_left_by_index(entities, 3)

    assert {:error, [1, 2, 3, 4, 5], :index_out_of_bounds} ==
             shift_left_by_index(1..5, 8)

    assert_raise ArgumentError, ~r/out of bounds/, fn ->
      shift_left_by_index!(entities, 3)
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_left_by_index!(entities, 0)

    assert {:error, [], :index_out_of_bounds} ==
             shift_right_by_index([], 0)

    assert {:error, [], :index_out_of_bounds} ==
             shift_right_by_index([], 5)

    assert_raise ArgumentError, ~r/not supported on maps/, fn ->
      shift_right_by_index(%{}, 5)
    end

    assert_raise ArgumentError, ~r/not supported on MapSet/, fn ->
      shift_right_by_index(MapSet.new([1, 2]), 0)
    end

    assert {:ok, [%{id: 2}], :not_shifted} ==
             shift_right_by_index([%{id: 2}], 0)

    assert {:error, [%{id: 2}], :index_out_of_bounds} ==
             shift_right_by_index([%{id: 2}], 5)

    assert {:ok, [%{id: 4}, %{id: 7}, %{id: 2}], :shifted} ==
             shift_right_by_index(entities, 1)

    assert {:ok, [%{id: 2}, %{id: 4}, %{id: 7}], :shifted} ==
             shift_right_by_index(entities, 0)

    assert {:ok, [%{id: 4}, %{id: 2}, %{id: 7}], :not_shifted} ==
             shift_right_by_index(entities, 2)

    assert {:error, [%{id: 4}, %{id: 2}, %{id: 7}], :index_out_of_bounds} ==
             shift_right_by_index(entities, 3)

    assert {:error, [1, 2, 3, 4, 5], :index_out_of_bounds} ==
             shift_right_by_index(1..5, 8)

    assert {:ok, [1, 2, 3, 5, 4], :shifted} ==
             shift_right_by_index(1..5, 3)

    assert {:ok, [1, 2, 3, 4, 5], :not_shifted} ==
             shift_right_by_index(1..5, 4)

    assert_raise ArgumentError, ~r/out of bounds/, fn ->
      shift_right_by_index!(entities, 3)
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_right_by_index!(entities, 2)
  end

  test "swap/3" do
    entities = [%{id: 4}, %{id: 2}, %{id: 7}]

    assert {:ok, [%{id: 7}, %{id: 2}, %{id: 4}], :swapped} ==
             swap(entities, 0, 2)

    assert {:ok, [1, 4, 3, 2, 5], :swapped} ==
             swap(1..5, 1, 3)

    assert {:ok, [1, 2, 3, 4, 5], :not_swapped} ==
             swap(1..5, 3, 3)

    assert {:error, [1, 2, 3, 4, 5], :index_out_of_bounds} ==
             swap(1..5, 1, 7)

    assert {:error, [], :index_out_of_bounds} ==
             swap([], 1, 7)

    assert [1, 4, 3, 2, 5] = swap!(1..5, 1, 3)

    assert_raise ArgumentError, ~r/out of bounds/, fn ->
      swap!(entities, 1, 3)
    end

    assert_raise ArgumentError, ~r/out of bounds/, fn ->
      swap!(entities, 3, 1)
    end

    assert_raise ArgumentError, ~r/out of bounds/, fn ->
      swap!(entities, 3, 3)
    end

    # Streams and other enumerables work correctly
    stream = Stream.map([1, 2, 3, 4, 5], & &1)
    assert {:ok, [1, 4, 3, 2, 5], :swapped} == swap(stream, 1, 3)
  end

  test "join/3" do
    assert "foo, bar and baz" == join(["foo", "bar", "baz"], ", ", " and ")
    assert "foo and bar" == join(["foo", "bar"], ", ", " and ")
    assert "foo" == join(["foo"], ", ", " and ")
    assert "" == join([], ", ", " and ")
  end

  test "decimal_sum/1" do
    assert Decimal.equal?(
             decimal_sum([Decimal.new("1.5"), Decimal.new("2.5"), Decimal.new("3.0")]),
             Decimal.new("7.0")
           )

    assert Decimal.equal?(decimal_sum([]), Decimal.new("0"))

    assert Decimal.equal?(
             decimal_sum([Decimal.new("-5"), Decimal.new("10")]),
             Decimal.new("5")
           )

    assert Decimal.equal?(
             decimal_sum([Decimal.new("0.1"), Decimal.new("0.2")]),
             Decimal.new("0.3")
           )
  end

  test "decimal_sum_by/2" do
    items = [
      %{price: Decimal.new("10.50")},
      %{price: Decimal.new("20.25")},
      %{price: Decimal.new("5.25")}
    ]

    assert Decimal.equal?(
             decimal_sum_by(items, & &1.price),
             Decimal.new("36.00")
           )

    assert Decimal.equal?(decimal_sum_by([], & &1.price), Decimal.new("0"))

    # With keyword list
    kw_items = [amount: Decimal.new("100"), amount: Decimal.new("200")]

    assert Decimal.equal?(
             decimal_sum_by(kw_items, fn {_k, v} -> v end),
             Decimal.new("300")
           )
  end
end
