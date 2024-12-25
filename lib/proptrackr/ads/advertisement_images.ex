defmodule Proptrackr.Ads.AdvertisementImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advertisement_images" do
    field :image_path, :string
    belongs_to :advertisement, Proptrackr.Ads.Advertisement

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:image_path, :advertisement_id])
    |> validate_required([:image_path, :advertisement_id])
  end
end
