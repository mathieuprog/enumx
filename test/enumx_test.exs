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
    assert all_equal?([foo: 1, foo: 1])
    refute all_equal?([foo: 1, foo: 2])
    refute all_equal?([foo: 1, bar: 1])
  end

  test "unique_value!/1" do
    assert_raise ArgumentError, fn ->
      unique_value!([])
    end
    assert_raise RuntimeError, fn ->
      unique_value!([1, 1, 2, 1])
    end
    assert_raise RuntimeError, fn ->
      unique_value!([foo: 1, bar: 1])
    end
    assert_raise RuntimeError, fn ->
      unique_value!([foo: 1, foo: 2])
    end
    assert_raise RuntimeError, fn ->
      unique_value!(%{foo: 1, bar: 1})
    end
    assert unique_value!([1, 1]) == 1
    assert unique_value!(%{foo: 1}) == {:foo, 1}
    assert unique_value!([foo: 1, foo: 1]) == {:foo, 1}
  end
end
