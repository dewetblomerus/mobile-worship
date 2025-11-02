defmodule MobileWorship.PresentationCacheTest do
  use ExUnit.Case, async: false

  alias MobileWorship.PresentationCache

  describe "presentation cache" do
    test "get_current_part/1 returns nil when no part is cached" do
      set_id = "test-set-#{:rand.uniform(10000)}"

      assert PresentationCache.get_current_part(set_id) == nil
    end

    test "put_current_part/2 and get_current_part/1 work together" do
      set_id = "test-set-#{:rand.uniform(10000)}"
      part = "cached part"

      assert PresentationCache.put_current_part(set_id, part) == :ok
      assert PresentationCache.get_current_part(set_id) == part
    end

    test "put_current_part/2 overwrites existing part" do
      set_id = "test-set-#{:rand.uniform(10000)}"
      part1 = "first part"
      part2 = "second part"

      PresentationCache.put_current_part(set_id, part1)
      assert PresentationCache.get_current_part(set_id) == part1

      PresentationCache.put_current_part(set_id, part2)
      assert PresentationCache.get_current_part(set_id) == part2
    end

    test "clear_current_part/1 removes cached part" do
      set_id = "test-set-#{:rand.uniform(10000)}"
      part = "test part"

      PresentationCache.put_current_part(set_id, part)
      assert PresentationCache.get_current_part(set_id) == part

      assert PresentationCache.clear_current_part(set_id) == :ok
      assert PresentationCache.get_current_part(set_id) == nil
    end

    test "different set_ids have independent cache entries" do
      set_id1 = "test-set-#{:rand.uniform(10000)}"
      set_id2 = "test-set-#{:rand.uniform(10000)}"
      part1 = "part for set 1"
      part2 = "part for set 2"

      PresentationCache.put_current_part(set_id1, part1)
      PresentationCache.put_current_part(set_id2, part2)

      assert PresentationCache.get_current_part(set_id1) == part1
      assert PresentationCache.get_current_part(set_id2) == part2
    end
  end
end
