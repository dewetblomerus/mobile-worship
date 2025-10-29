defmodule MobileWorship.Sets.Set do
  @moduledoc """
  Schema for sets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "sets" do
    field :name, :string
    field :song_ids, {:array, :integer}

    belongs_to :organization, MobileWorship.Organizations.Organization, type: :integer
    belongs_to :created_by, MobileWorship.Accounts.User, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:name, :song_ids])
    |> validate_required([:name])
  end
end
