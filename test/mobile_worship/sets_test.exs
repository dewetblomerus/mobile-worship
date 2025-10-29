defmodule MobileWorship.SetsTest do
  use MobileWorship.DataCase

  alias MobileWorship.Sets

  describe "sets" do
    alias MobileWorship.Sets.Set

    import MobileWorship.AccountsFixtures
    import MobileWorship.SetsFixtures

    @invalid_attrs %{name: nil}

    test "list_sets/1 returns all sets for an organization" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      set = set_fixture(%{user: user})
      assert Sets.list_sets(organization.id) == [set]
    end

    test "get_set!/2 returns the set with given id and organization" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      set = set_fixture(%{user: user})
      assert Sets.get_set!(set.id, organization.id) == set
    end

    test "create_set/3 with valid data creates a set" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      valid_attrs = %{name: "some name", song_ids: []}

      assert {:ok, %Set{} = set} = Sets.create_set(user, organization.id, valid_attrs)
      assert set.name == "some name"
      assert set.song_ids == []
    end

    test "create_set/3 with invalid data returns error changeset" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      assert {:error, %Ecto.Changeset{}} = Sets.create_set(user, organization.id, @invalid_attrs)
    end

    test "update_set/2 with valid data updates the set" do
      set = set_fixture()
      update_attrs = %{name: "some updated name", song_ids: [1]}

      assert {:ok, %Set{} = set} = Sets.update_set(set, update_attrs)
      assert set.name == "some updated name"
      assert set.song_ids == [1]
    end

    test "update_set/2 with invalid data returns error changeset" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      set = set_fixture(%{user: user})
      assert {:error, %Ecto.Changeset{}} = Sets.update_set(set, @invalid_attrs)
      assert set == Sets.get_set!(set.id, organization.id)
    end

    test "delete_set/1 deletes the set" do
      user = user_fixture()
      organization = MobileWorship.Accounts.get_personal_organization(user.id)
      set = set_fixture(%{user: user})
      assert {:ok, %Set{}} = Sets.delete_set(set)
      assert_raise Ecto.NoResultsError, fn -> Sets.get_set!(set.id, organization.id) end
    end

    test "change_set/1 returns a set changeset" do
      set = set_fixture()
      assert %Ecto.Changeset{} = Sets.change_set(set)
    end
  end
end
