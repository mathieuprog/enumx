defmodule Enumx do
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

  def all_equal?(list) when is_list(list) do
    first = hd(list)
    Enum.all?(list, &(&1 == first))
  end

  def all_equal?(enum) when is_map(enum) do
    all_equal?(Map.to_list(enum))
  end

  @doc """
  Ensures that all elements in `enumerable` are equal, otherwise raises an error.
  If all elements are equal, it returns one of those elements.
  """
  def unique_value!([]), do: raise(ArgumentError, message: "cannot call `unique_value!/1` on an empty list")

  def unique_value!(list) when is_list(list) do
    if all_equal?(list) do
      hd(list)
    else
      raise "elements in the list #{inspect(list)} are not equal"
    end
  end

  def unique_value!(enum) when is_map(enum) do
    unique_value!(Map.to_list(enum))
  end
end
