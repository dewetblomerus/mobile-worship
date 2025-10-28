defmodule MobileWorship.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias MobileWorship.Repo

  alias MobileWorship.Content.Song

  @doc """
  Returns the list of songs for a given organization.

  ## Examples

      iex> list_songs(organization_id)
      [%Song{}, ...]

  """
  def list_songs(organization_id) do
    Song
    |> where([s], s.organization_id == ^organization_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single song for a given organization.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123, organization_id)
      %Song{}

      iex> get_song!(456, organization_id)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id, organization_id) do
    Song
    |> where([s], s.id == ^id and s.organization_id == ^organization_id)
    |> Repo.one!()
  end

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(user, organization_id, %{field: value})
      {:ok, %Song{}}

      iex> create_song(user, organization_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(user, organization_id, attrs) do
    %Song{}
    |> Song.changeset(attrs)
    |> Ecto.Changeset.put_change(:organization_id, organization_id)
    |> Ecto.Changeset.put_change(:created_by_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end
end
