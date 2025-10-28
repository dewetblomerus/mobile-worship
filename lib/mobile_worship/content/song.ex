defmodule MobileWorship.Content.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :name, :string
    field :parts, {:array, :string}

    belongs_to :organization, MobileWorship.Organizations.Organization
    belongs_to :created_by, MobileWorship.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:name, :parts])
    |> validate_required([:name])
  end
end
