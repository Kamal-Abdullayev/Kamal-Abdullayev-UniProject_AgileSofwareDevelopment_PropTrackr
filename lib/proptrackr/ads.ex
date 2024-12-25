defmodule Proptrackr.Ads do
  import Ecto.Query, warn: false
  alias Proptrackr.Repo
  alias Proptrackr.Ads.Advertisement
  alias Proptrackr.Locations.Location

  @doc """
  Returns the list of advertisements.

  ## Examples

      iex> list_advertisements()
      [%Advertisement{}, ...]

  """
  def list_advertisements do
    Repo.all(Advertisement)
  end

  @doc """
  Gets a single advertisement.

  Raises `Ecto.NoResultsError` if the Advertisement does not exist.

  ## Examples

      iex> get_advertisement!(123)
      %Advertisement{}

      iex> get_advertisement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_advertisement!(id), do: Repo.get!(Advertisement, id)

  @doc """
  Creates an advertisement with a generated reference number.

  ## Examples

      iex> create_advertisement(%{field: value})
      {:ok, %Advertisement{}}

      iex> create_advertisement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_advertisement(attrs \\ %{}) do
    reference_number = generate_reference_number()

    %Advertisement{}
    |> Advertisement.changeset(Map.put(attrs, "reference_number", reference_number))
    |> Repo.insert()
  end

  @doc """
  Updates an advertisement.

  ## Examples

      iex> update_advertisement(advertisement, %{field: new_value})
      {:ok, %Advertisement{}}

      iex> update_advertisement(advertisement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_advertisement(%Advertisement{} = advertisement, attrs) do
    advertisement
    |> Advertisement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an advertisement.

  ## Examples

      iex> delete_advertisement(advertisement)
      {:ok, %Advertisement{}}

      iex> delete_advertisement(advertisement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_advertisement(%Advertisement{} = advertisement) do
    Repo.delete(advertisement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking advertisement changes.

  ## Examples

      iex> change_advertisement(advertisement)
      %Ecto.Changeset{data: %Advertisement{}}

  """
  def change_advertisement(%Advertisement{} = advertisement, attrs \\ %{}) do
    Advertisement.changeset(advertisement, attrs)
  end

  defp generate_reference_number do
    # Using UUID for unique reference number generation
    UUID.uuid4()
  end

  def list_advertisements_for_user(user_id) do
    Repo.all(from a in Advertisement, where: a.user_id == ^user_id)
  end

  def get_recommended_properties(advertisement, limit \\ 5) do
    price_difference =
      case advertisement.type do
        "Rent" -> 300
        "Sale" -> 20000
        _ -> 10000  # Default to Sale price difference
      end

    Repo.all(
      from a in Advertisement,
        where: a.id != ^advertisement.id,
        where: a.type == ^advertisement.type,  # Filter by the same type (Rent or Sale)
        where: fragment("ABS(? - ?) < ?", a.price, ^advertisement.price, ^price_difference),
        where: fragment("ABS(? - ?) <= ?", a.rooms, ^advertisement.rooms, 1),
        where: fragment("ABS(? - ?) < ?", a.square_meters, ^advertisement.square_meters, 20),
        limit: ^limit
    )
  end



  # List all unique countries
  def list_countries do
    Repo.all(from l in Location, select: l.country, distinct: true)
  end

  # Get all cities for a given country
  def get_cities_for_country(country) do
    Repo.all(from l in Location, where: l.country == ^country, select: l.city, distinct: true)
  end

  # Get all areas for a given country and city
  def get_areas_for_city(country, city) do
    Repo.all(from l in Location, where: l.country == ^country and l.city == ^city, select: l.area, distinct: true)
  end

end
