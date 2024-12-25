defmodule Proptrackr.Accounts.UserFavoriteAds do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_favorite_ads" do
    belongs_to :user, Proptrackr.Accounts.User
    belongs_to :advertisement, Proptrackr.Ads.Advertisement

    timestamps(type: :utc_datetime)
  end

  def changeset(user_favorite, attrs) do
    user_favorite
    |> cast(attrs, [:user_id, :advertisement_id])
    |> validate_required([:user_id, :advertisement_id])
    |> unique_constraint(:user_id, name: :user_favorite_ads_user_id_advertisement_id_index, message: "You have already marked this advertisement as 'Favorite'.")
  end

end
