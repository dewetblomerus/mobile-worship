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
  Gets a single set by ID without organization check.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set_by_id!(123)
      %Set{}

      iex> get_set_by_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_set_by_id!(id) do
    Repo.get!(Set, id)
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

  @doc """
  Returns all songs in a set with their parts.

  Each song is represented as a map with id, name, and parts.

  ## Examples

      iex> get_set_songs(set, organization_id)
      [%{id: 1, name: "Song 1", parts: ["Verse 1...", "Chorus..."]}, ...]

  """
  def get_set_songs(%Set{} = set, organization_id) do
    alias MobileWorship.Content.Song

    if is_nil(set.song_ids) or set.song_ids == [] do
      []
    else
      songs =
        Song
        |> where([s], s.id in ^set.song_ids and s.organization_id == ^organization_id)
        |> Repo.all()

      song_map = Map.new(songs, fn song -> {song.id, song} end)

      set.song_ids
      |> Enum.map(fn song_id -> build_song_map(song_map, song_id) end)
      |> Enum.reject(&is_nil/1)
    end
  end

  @doc """
  Returns all parts from all songs in a set, flattened into a single list.

  Each part is represented as a map with the song name and part content.

  ## Examples

      iex> get_set_parts(set, organization_id)
      [%{song_name: "Song 1", content: "Verse 1..."}, ...]

  """
  def get_set_parts(%Set{} = set, organization_id) do
    set
    |> get_set_songs(organization_id)
    |> Enum.flat_map(fn song -> flatten_song_parts(song) end)
  end

  defp build_song_map(song_map, song_id) do
    case Map.get(song_map, song_id) do
      nil ->
        nil

      song ->
        %{
          id: song.id,
          name: song.name,
          parts: song.parts || []
        }
    end
  end

  defp flatten_song_parts(song) do
    Enum.map(song.parts, fn part ->
      %{
        song_name: song.name,
        content: part
      }
    end)
  end
end
