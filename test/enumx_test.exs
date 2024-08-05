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
  end

  test "with_index_length/2" do
    assert [{0, :foo}, {1, :bar}, {2, :baz}] ==
             Enum.with_index([:foo, :bar, :baz], fn el, i -> {i, el} end)

    assert [{3, 0, :foo}, {3, 1, :bar}, {3, 2, :baz}] ==
             with_index_length([:foo, :bar, :baz], fn el, i, length -> {length, i, el} end)

    assert [{:foo, 5}, {:bar, 6}, {:baz, 7}] == Enum.with_index([:foo, :bar, :baz], 5)
    assert [{:foo, 5, 3}, {:bar, 6, 3}, {:baz, 7, 3}] == with_index_length([:foo, :bar, :baz], 5)
  end

  test "unique_value!/1" do
    assert_raise ArgumentError, fn ->
      unique_value!([])
    end

    assert_raise RuntimeError, fn ->
      unique_value!([1, 1, 2, 1])
    end

    assert_raise RuntimeError, fn ->
      unique_value!(foo: 1, bar: 1)
    end

    assert_raise RuntimeError, fn ->
      unique_value!(foo: 1, foo: 2)
    end

    assert_raise RuntimeError, fn ->
      unique_value!(%{foo: 1, bar: 1})
    end

    assert unique_value!([1, 1]) == 1
    assert unique_value!(%{foo: 1}) == {:foo, 1}
    assert unique_value!(foo: 1, foo: 1) == {:foo, 1}
  end
end
