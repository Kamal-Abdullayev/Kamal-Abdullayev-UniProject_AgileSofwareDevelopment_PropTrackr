defmodule Proptrackr.Search.Filter do
  use Ecto.Schema
  import Ecto.Changeset


  # Define your schema here
  schema "filter" do
    field :search, :string
    field :country, :string
    field :city, {:array, :string}
    field :area, {:array, :string}
    field :min_price, :integer
    field :max_price, :integer
    field :min_rooms, :integer
    field :max_rooms, :integer
  end

  # Changeset function to validate the form fields
  def changeset(search_params, params) do
    search_params
    |> cast(params, [:search, :country, :city, :area, :min_price, :max_price, :min_rooms, :max_rooms])
    |> validate_number(:min_price, greater_than_or_equal_to: 0)
    |> validate_number(:max_price, greater_than_or_equal_to: 0)
    |> validate_number(:min_rooms, greater_than_or_equal_to: 1)
    |> validate_number(:max_rooms, greater_than_or_equal_to: 1)
    |> validate_price_range()
  end

  # Custom validation for price range
  defp validate_price_range(changeset) do
    min_price = get_field(changeset, :min_price)
    max_price = get_field(changeset, :max_price)

    if min_price && max_price && min_price > max_price do
      add_error(changeset, :min_price, "must be less than or equal to maximum price")
    else
      changeset
    end
  end
end
