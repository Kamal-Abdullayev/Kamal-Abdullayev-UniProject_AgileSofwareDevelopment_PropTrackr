defmodule Proptrackr.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :country, :string
    field :city, :string
    field :area, :string
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:country,:city,:area])
    |> validate_required([:country,:city,:area])
  end
end
