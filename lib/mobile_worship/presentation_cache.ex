defmodule MobileWorship.PresentationCache do
  @moduledoc """
  ETS-based cache for storing the current presentation state of sets.
  This allows viewers joining mid-presentation to immediately see the current slide
  instead of waiting for the next PubSub update.
  """

  use Agent

  @table_name :presentation_cache

  @doc """
  Starts the ETS table for the presentation cache.
  This should be called once during application startup.
  """
  def start_link(_opts) do
    Agent.start_link(
      fn ->
        :ets.new(@table_name, [:set, :public, :named_table])
      end,
      name: __MODULE__
    )
  end

  @doc """
  Stores the current part being presented for a given set.
  """
  def put_current_part(set_id, part) do
    key = cache_key(set_id)
    :ets.insert(@table_name, {key, part})
    :ok
  end

  @doc """
  Retrieves the current part being presented for a given set.
  Returns `nil` if no part is currently cached.
  """
  def get_current_part(set_id) do
    key = cache_key(set_id)

    case :ets.lookup(@table_name, key) do
      [{^key, part}] -> part
      [] -> nil
    end
  end

  @doc """
  Clears the cached current part for a given set.
  Useful when a presentation ends.
  """
  def clear_current_part(set_id) do
    key = cache_key(set_id)
    :ets.delete(@table_name, key)
    :ok
  end

  defp cache_key(set_id) do
    "current_set_slide:#{set_id}"
  end
end
