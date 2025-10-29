defmodule MobileWorship.Sets do
  @moduledoc """
  The Sets context.
  """

  import Ecto.Query, warn: false
  alias MobileWorship.Repo

  alias MobileWorship.Sets.Set

  @doc """
  Returns the list of sets for a given organization.

  ## Examples

      iex> list_sets(organization_id)
      [%Set{}, ...]

  """
  def list_sets(organization_id) do
    Set
    |> where([s], s.organization_id == ^organization_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single set for a given organization.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set!(123, organization_id)
      %Set{}

      iex> get_set!(456, organization_id)
      ** (Ecto.NoResultsError)

  """
  def get_set!(id, organization_id) do
    Set
    |> where([s], s.id == ^id and s.organization_id == ^organization_id)
    |> Repo.one!()
  end

  @doc """
  Creates a set.

  ## Examples

      iex> create_set(user, organization_id, %{field: value})
      {:ok, %Set{}}

      iex> create_set(user, organization_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_set(user, organization_id, attrs) do
    %Set{}
    |> Set.changeset(attrs)
    |> Ecto.Changeset.put_change(:organization_id, organization_id)
    |> Ecto.Changeset.put_change(:created_by_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a set.

  ## Examples

      iex> update_set(set, %{field: new_value})
      {:ok, %Set{}}

      iex> update_set(set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_set(%Set{} = set, attrs) do
    set
    |> Set.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a set.

  ## Examples

      iex> delete_set(set)
      {:ok, %Set{}}

      iex> delete_set(set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_set(%Set{} = set) do
    Repo.delete(set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking set changes.

  ## Examples

      iex> change_set(set)
      %Ecto.Changeset{data: %Set{}}

  """
  def change_set(%Set{} = set, attrs \\ %{}) do
    Set.changeset(set, attrs)
  end
end
