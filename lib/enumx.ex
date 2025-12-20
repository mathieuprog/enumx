defmodule Enumx do
  defguard is_plain_map(term) when is_map(term) and not is_struct(term)

  @doc """
  Similar to filter/2, but returns the value of the function invocation instead of the element itself
  """
  def filter_value(enum, fun) do
    Enum.flat_map(enum, &if(value = fun.(&1), do: [value], else: []))
  end

  @doc """
  Returns `true` if all elements in `enumerable` are equal.
  """
  def all_equal?([]), do: true

  def all_equal?(enum) when is_list(enum) do
    first = hd(enum)
    Enum.all?(enum, &(&1 == first))
  end

  def all_equal?(enum) when is_map(enum) do
    all_equal?(Map.to_list(enum))
  end

  @doc """
  Returns tuples of each element, its index, and the total length of the enumerable.
  """
  def with_index_length(enum, fun_or_offset \\ 0)

  def with_index_length(enum, fun) when is_function(fun, 3) do
    length = Enum.count(enum)
    Enum.with_index(enum, fn element, index -> fun.(element, index, length) end)
  end

  def with_index_length(enum, offset) when is_integer(offset) do
    length = Enum.count(enum)
    Enum.with_index(enum, fn element, index -> {element, index + offset, length} end)
  end

  @doc """
  Returns each element and the result of a function taking the element. A static value can also be added to each element.
  """
  def with_value(enum, fun) when is_function(fun, 1) do
    Enum.map(enum, &{&1, fun.(&1)})
  end

  def with_value(enum, value) do
    Enum.map(enum, &{&1, value})
  end

  @doc """
  Returns the single unique element if all elements in enumerable are equal; otherwise, raises an error.
  """
  def unique_value!([]),
    do: raise(ArgumentError, message: "cannot get unique value from empty enumerable")

  def unique_value!(list) when is_list(list) do
    if all_equal?(list) do
      hd(list)
    else
      raise(ArgumentError, message: "elements in enumerable are not equal")
    end
  end

  def unique_value!(enum) when is_map(enum) do
    unique_value!(Map.to_list(enum))
  end

  @doc """
  Returns the only element if the enumerable contains exactly one element; otherwise, raises.
  """
  def one!([]),
    do: raise(ArgumentError, message: "expected single element, got none")

  def one!([element]), do: element

  def one!(list) when is_list(list),
    do: raise(ArgumentError, message: "expected single element, got #{length(list)}")

  def one!(map) when is_plain_map(map) and map_size(map) == 0,
    do: raise(ArgumentError, message: "expected single element, got none")

  def one!(map) when is_plain_map(map) and map_size(map) == 1,
    do: map |> Map.to_list() |> hd()

  def one!(map) when is_plain_map(map),
    do: raise(ArgumentError, message: "expected single element, got #{map_size(map)}")

  def one!(enum) do
    case Enum.take(enum, 2) do
      [] -> raise(ArgumentError, message: "expected single element, got none")
      [element] -> element
      [_, _] -> raise(ArgumentError, message: "expected single element, got multiple")
    end
  end

  def shift_left_by_index([], _index), do: {:error, [], :index_out_of_bounds}

  def shift_left_by_index(enum, _index) when is_plain_map(enum) do
    raise ArgumentError, message: "index-based operations not supported on maps (unordered)"
  end

  def shift_left_by_index(%MapSet{}, _index) do
    raise ArgumentError, message: "index-based operations not supported on MapSet (unordered)"
  end

  def shift_left_by_index(enum, 0), do: {:ok, enum, :not_shifted}

  def shift_left_by_index(enum, index) do
    {enum, shifted?, _index} = do_shift_by_index(enum, index)

    enum = Enum.reverse(enum)

    cond do
      shifted? ->
        {:ok, enum, :shifted}

      true ->
        {:error, enum, :index_out_of_bounds}
    end
  end

  def shift_left_by_index!(enum, index) do
    case shift_left_by_index(enum, index) do
      {:ok, enum, _} ->
        enum

      {:error, _, _} ->
        raise ArgumentError, message: "index #{index} out of bounds (size: #{Enum.count(enum)})"
    end
  end

  def shift_right_by_index([], _index), do: {:error, [], :index_out_of_bounds}

  def shift_right_by_index(enum, _index) when is_plain_map(enum) do
    raise ArgumentError, message: "index-based operations not supported on maps (unordered)"
  end

  def shift_right_by_index(%MapSet{}, _index) do
    raise ArgumentError, message: "index-based operations not supported on MapSet (unordered)"
  end

  def shift_right_by_index(enum, index) do
    index = Enum.count(enum) - index - 1

    {enum, shifted?, index} =
      enum
      |> Enum.reverse()
      |> do_shift_by_index(index)

    cond do
      shifted? ->
        {:ok, enum, :shifted}

      index == 0 ->
        {:ok, enum, :not_shifted}

      true ->
        {:error, enum, :index_out_of_bounds}
    end
  end

  def shift_right_by_index!(enum, index) do
    case shift_right_by_index(enum, index) do
      {:ok, enum, _} ->
        enum

      {:error, _, _} ->
        raise ArgumentError, message: "index #{index} out of bounds (size: #{Enum.count(enum)})"
    end
  end

  defp do_shift_by_index(enum, index_to_shift) do
    {result, shifted?, index} =
      Enum.reduce_while(enum, {[], false, 0}, fn element, {acc, shifted?, current_index} ->
        cond do
          !shifted? and index_to_shift == current_index ->
            if current_index == 0 do
              {:halt, {Enum.reverse(enum), false, 0}}
            else
              [e1 | rest] = acc
              {:cont, {[e1, element | rest], true, current_index + 1}}
            end

          true ->
            {:cont, {[element | acc], shifted?, current_index + 1}}
        end
      end)

    {result, shifted?, index}
  end

  def shift_first_match_left(enum, element_to_shift, compare_fn \\ &(&1 == &2))

  def shift_first_match_left([], _, _), do: {:error, [], :element_not_found}

  def shift_first_match_left(enum, _, _) when is_plain_map(enum) do
    raise ArgumentError, message: "index-based operations not supported on maps (unordered)"
  end

  def shift_first_match_left(%MapSet{}, _, _) do
    raise ArgumentError, message: "index-based operations not supported on MapSet (unordered)"
  end

  def shift_first_match_left(enum, element_to_shift, compare_fn) do
    {enum, shifted?, index} =
      do_shift_first(enum, element_to_shift, compare_fn)

    enum = Enum.reverse(enum)

    cond do
      shifted? ->
        {:ok, enum, :shifted}

      index == 0 ->
        {:ok, enum, :not_shifted}

      true ->
        {:error, enum, :element_not_found}
    end
  end

  def shift_first_match_left!(enum, element_to_shift, compare_fn \\ &(&1 == &2)) do
    case shift_first_match_left(enum, element_to_shift, compare_fn) do
      {:ok, enum, _} ->
        enum

      {:error, _, _} ->
        raise ArgumentError, message: "element #{inspect(element_to_shift)} not found"
    end
  end

  def shift_first_match_right(enum, element_to_shift, compare_fn \\ &(&1 == &2))

  def shift_first_match_right([], _, _), do: {:error, [], :element_not_found}

  def shift_first_match_right(enum, _, _) when is_plain_map(enum) do
    raise ArgumentError, message: "index-based operations not supported on maps (unordered)"
  end

  def shift_first_match_right(%MapSet{}, _, _) do
    raise ArgumentError, message: "index-based operations not supported on MapSet (unordered)"
  end

  def shift_first_match_right(enum, element_to_shift, compare_fn) do
    {enum, shifted?, index} =
      enum
      |> Enum.reverse()
      |> do_shift_first(element_to_shift, compare_fn)

    cond do
      shifted? ->
        {:ok, enum, :shifted}

      index == 0 ->
        {:ok, enum, :not_shifted}

      true ->
        {:error, enum, :element_not_found}
    end
  end

  def shift_first_match_right!(enum, element_to_shift, compare_fn \\ &(&1 == &2)) do
    case shift_first_match_right(enum, element_to_shift, compare_fn) do
      {:ok, enum, _} ->
        enum

      {:error, _, _} ->
        raise ArgumentError, message: "element #{inspect(element_to_shift)} not found"
    end
  end

  defp do_shift_first(enum, element_to_shift, compare_fn) do
    {result, shifted?, index} =
      Enum.reduce_while(enum, {[], false, 0}, fn current_element, {acc, shifted?, index} ->
        cond do
          !shifted? and compare_fn.(current_element, element_to_shift) ->
            if index == 0 do
              {:halt, {Enum.reverse(enum), false, 0}}
            else
              [e1 | rest] = acc
              {:cont, {[e1, current_element | rest], true, index + 1}}
            end

          true ->
            {:cont, {[current_element | acc], shifted?, index + 1}}
        end
      end)

    {result, shifted?, index}
  end

  def swap([], _i1, _i2), do: {:error, [], :index_out_of_bounds}

  def swap(enum, _i1, _i2) when is_plain_map(enum) do
    raise ArgumentError, message: "index-based operations not supported on maps (unordered)"
  end

  def swap(%MapSet{}, _, _) do
    raise ArgumentError, message: "index-based operations not supported on MapSet (unordered)"
  end

  def swap(%{} = enum, i1, i2) do
    swap(Enum.to_list(enum), i1, i2)
  end

  def swap(enum, i1, i2) do
    e1 = Enum.at(enum, i1, :none)
    e2 = Enum.at(enum, i2, :none)

    do_swap(enum, {i1, e1}, {i2, e2})
  end

  def do_swap(enum, {_, :none}, _),
    do: {:error, Enum.to_list(enum), :index_out_of_bounds}

  def do_swap(enum, _, {_, :none}),
    do: {:error, Enum.to_list(enum), :index_out_of_bounds}

  def do_swap(enum, {i1, _e1}, {i1, _e2}) do
    {:ok, Enum.to_list(enum), :not_swapped}
  end

  def do_swap(enum, {i1, e1}, {i2, e2}) do
    enum =
      enum
      |> List.replace_at(i1, e2)
      |> List.replace_at(i2, e1)

    {:ok, enum, :swapped}
  end

  def swap!(enum, i1, i2) do
    case swap(enum, i1, i2) do
      {:ok, enum, _} ->
        enum

      {:error, _, _} ->
        count = Enum.count(enum)

        if i1 > count - 1 && i2 > count - 1 do
          raise ArgumentError, message: "indices #{i1} and #{i2} out of bounds (size: #{count})"
        end

        if i1 > count - 1 do
          raise ArgumentError, message: "index #{i1} out of bounds (size: #{count})"
        end

        raise ArgumentError, message: "index #{i2} out of bounds (size: #{count})"
    end
  end

  def join(enum, join, last_join)
      when is_list(enum) and is_binary(join) and is_binary(last_join) do
    do_join(enum, join, last_join, "")
  end

  defp do_join([], _join, _last_join, acc), do: acc
  defp do_join([head | tail], join, last_join, ""), do: do_join(tail, join, last_join, head)
  defp do_join([last | []], _join, last_join, acc), do: acc <> last_join <> last

  defp do_join([head | tail], join, last_join, acc),
    do: do_join(tail, join, last_join, acc <> join <> head)

  if Code.ensure_loaded?(Decimal) do
    def decimal_sum(enum) do
      Enum.reduce(enum, Decimal.new(0), &Decimal.add/2)
    end

    def decimal_sum_by(enum, fun) when is_function(fun, 1) do
      Enum.reduce(enum, Decimal.new(0), fn element, acc ->
        Decimal.add(acc, fun.(element))
      end)
    end
  end
end
