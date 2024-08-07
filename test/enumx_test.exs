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

  test "unique_value!/1" do
    assert_raise ArgumentError, fn ->
      unique_value!([])
    end

    assert_raise ArgumentError, fn ->
      unique_value!(%{})
    end

    assert_raise RuntimeError, fn ->
      unique_value!(1..5)
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

  test "shift_first_match_left/3 and shift_first_match_right/3" do
    entities = [%{id: 4}, %{id: 2}, %{id: 7}]
    entities_kw = [id: 4, id: 2, id: 7]

    assert {:error, [], :element_not_found} ==
             shift_first_match_left([], %{id: 2}, &(&1.id == &2.id))

    assert_raise RuntimeError, fn ->
      shift_first_match_left(%{}, {:id, 2}, &(&1.id == &2.id))
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

    assert_raise RuntimeError, fn ->
      shift_first_match_left!(entities, %{id: 8}, &(&1.id == &2.id))
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_first_match_left!(entities, %{id: 4}, &(&1.id == &2.id))

    assert {:error, [], :element_not_found} ==
             shift_first_match_right([], %{id: 2}, &(&1.id == &2.id))

    assert_raise RuntimeError, fn ->
      shift_first_match_right(%{}, {:id, 2}, &(&1.id == &2.id))
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

    assert_raise RuntimeError, fn ->
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

    assert_raise RuntimeError, fn ->
      shift_left_by_index(%{}, 5)
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

    assert_raise RuntimeError, fn ->
      shift_left_by_index!(entities, 3)
    end

    assert [%{id: 4}, %{id: 2}, %{id: 7}] ==
             shift_left_by_index!(entities, 0)

    assert {:error, [], :index_out_of_bounds} ==
             shift_right_by_index([], 0)

    assert {:error, [], :index_out_of_bounds} ==
             shift_right_by_index([], 5)

    assert_raise RuntimeError, fn ->
      shift_right_by_index(%{}, 5)
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

    assert_raise RuntimeError, fn ->
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

    assert_raise RuntimeError, fn ->
      swap!(entities, 1, 3)
    end

    assert_raise RuntimeError, fn ->
      swap!(entities, 3, 1)
    end

    assert_raise RuntimeError, fn ->
      swap!(entities, 3, 3)
    end
  end
end
