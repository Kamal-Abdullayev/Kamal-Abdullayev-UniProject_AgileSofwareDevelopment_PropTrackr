defmodule Proptrackr.Ads.Advertisement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advertisements" do
    field :type, :string
    field :floor, :integer
    field :state, :string
    field :description, :string
    field :title, :string
    field :phone_number, :string
    field :street, :string
    field :reference, :string
    field :price, :decimal
    field :square_meters, :integer
    field :rooms, :integer
    field :total_floors, :integer
    field :photo_paths, {:array, :string}
    belongs_to :user, Proptrackr.Accounts.User
    field :country, :string
    field :city, :string
    field :area, :string
    field :recommended_price, :decimal, virtual: true


    has_many :images, Proptrackr.Ads.AdvertisementImage, foreign_key: :advertisement_id
    has_many :user_not_interesting_ads, Proptrackr.Accounts.UserNotInterested
    has_many :users_not_interested, through: [:user_not_interesting_ads, :user]

    timestamps(type: :utc_datetime)
  end

  def calculate_recommended_price(%__MODULE__{
    square_meters: square_meters,
    rooms: rooms,
    area: area,
    type: type
  }) do
    square_meters = square_meters || 0
    rooms = rooms || 0
    area = String.downcase(area || "other")
    type = type || "Sale"

    base_price_per_square_meter =
      case area do
        "karlova" -> 1000
        "annelinn" -> 950
        "kesklinn" -> 900
        "supilinn" -> 800
        "vaksali" -> 700
        "kadriorg" -> 600
        "mereäärne" -> 500
        "kallio" -> 400
        "punavuori" -> 350
        "kauppi" -> 550
        "auranranta" -> 500
        _ -> 600
      end

    room_modifier = rooms * 1
    sale_price = base_price_per_square_meter * square_meters * (1 + room_modifier)

    case type do
      "Rent" ->
        sale_price * 0.005

      "Sale" ->
        sale_price

      _ ->
        raise ArgumentError, "Invalid type: #{type}. Must be 'Rent' or 'Sale'."
    end
  end

  @doc false
  def changeset(advertisement, attrs) do
    advertisement
    |> cast(attrs, [
      :title, :description, :price, :photo_paths, :type, :square_meters, :street,
      :rooms, :floor, :total_floors, :reference, :state, :user_id, :phone_number,
      :country, :city, :area
    ])
    |> cast_assoc(:images, with: &Proptrackr.Ads.AdvertisementImage.changeset/2) # Handles associated images
    |> assign_reference_number()
    |> validate_required([
      :title, :price, :square_meters, :street, :type, :user_id, :country, :city, :area
    ])
    |> validate_length(:title, min: 1)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:square_meters, greater_than: 0)
    |> validate_number(:rooms, greater_than_or_equal_to: 0)
    |> validate_number(:floor, greater_than_or_equal_to: 0)
    |> validate_number(:total_floors, greater_than_or_equal_to: 0)
    |> validate_floor_not_greater_than_total_floors()
    |> validate_phone_number()
    |> calculate_and_validate_recommended_price()
  end


  defp calculate_and_validate_recommended_price(changeset) do
    advertisement = apply_changes(changeset)

    recommended_price = calculate_recommended_price(advertisement)

    changeset
    |> put_change(:recommended_price, recommended_price)
    |> validate_number(:recommended_price, greater_than: 0, message: "must be greater than 0")
  end

  defp validate_phone_number(changeset) do
    phone_number = get_field(changeset, :phone_number)

    if phone_number && !valid_phone_number?(phone_number) do
      add_error(changeset, :phone_number, "is invalid. Please enter a valid Estonian phone number.")
    else
      changeset
    end
  end

  defp valid_phone_number?(phone_number) do
    regex = ~r/^\+?372[\s\-\.]?\d{4}[\s\-\.]?\d{4}$/
    Regex.match?(regex, phone_number)
  end

  defp assign_reference_number(changeset) do
    case get_field(changeset, :reference) do
      nil -> put_change(changeset, :reference, generate_reference_number())
      _ -> changeset
    end
  end

  defp generate_reference_number do
    UUID.uuid4()  # Generates a unique UUID each time
  end

  defp validate_floor_not_greater_than_total_floors(changeset) do
    floor = get_field(changeset, :floor)
    total_floors = get_field(changeset, :total_floors)

    if floor && total_floors && floor > total_floors do
      add_error(changeset, :floor, "cannot be greater than total floors")
    else
      changeset
    end
  end
end
