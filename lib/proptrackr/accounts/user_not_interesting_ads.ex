defmodule Proptrackr.Accounts.UserNotInterested do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_not_interesting_ads" do
    belongs_to :user, Proptrackr.Accounts.User
    belongs_to :advertisement, Proptrackr.Ads.Advertisement

    timestamps(type: :utc_datetime)
  end

  def changeset(user_not_interested, attrs) do
    user_not_interested
    |> cast(attrs, [:user_id, :advertisement_id])
    |> validate_required([:user_id, :advertisement_id])
    |> unique_constraint(:user_id, name: :user_not_interesting_ads_user_id_advertisement_id_index, message: "You have already marked this advertisement as 'Not Interested'.")
  end

end
