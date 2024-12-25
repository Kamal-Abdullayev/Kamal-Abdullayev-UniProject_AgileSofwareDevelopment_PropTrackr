defmodule Proptrackr.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :birthdate, :date
    field :phone, :string
    field :description, :string
    field :is_admin, :boolean, default: false
    field :is_blocked, :boolean, default: false
    has_many :ads, Proptrackr.Ads.Advertisement

    has_many :user_not_interesting_ads, Proptrackr.Accounts.UserNotInterested
    has_many :not_interesting_ads, through: [:user_not_interesting_ads, :advertisement]
    has_many :user_favorite_ads, Proptrackr.Accounts.UserFavoriteAds
    has_many :favorite_ads, through: [:user_favorite_ads, :advertisement]

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}, with_password \\ true) do
    struct
    |> cast(params, [:firstname, :lastname,:email,:password, :birthdate, :phone, :description, :is_blocked])
    |> validate_required([:firstname, :lastname, :email])
    |> unique_constraint(:email)
    |> maybe_validate_password(with_password)
  end

  defp maybe_validate_password(changeset, true) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> hash_password
  end

  defp maybe_validate_password(changeset, false), do: changeset

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(password))
  end
  defp hash_password(changeset), do: changeset

    # Function to validate the old password and change the password
    def change_password_changeset(user, %{"old_password" => old_password, "password" => password, "password_confirmation" => password_confirmation}) do
      user
      |> cast(%{"password" => password, "password_confirmation" => password_confirmation}, [:password, :password_confirmation])
      |> validate_required([:password, :password_confirmation])
      |> validate_length(:password, min: 6)
      |> validate_confirmation(:password)
      |> check_old_password(old_password)
      |> hash_password
    end

    # Validate the old password
    defp check_old_password(changeset, old_password) do
      case changeset.valid? do
        true ->
          user = changeset.data
          if Pbkdf2.verify_pass(old_password, user.hashed_password) do
            changeset
          else
            add_error(changeset, :old_password, "Old password is incorrect")
          end

        false ->
          changeset
      end
    end

    def block_changeset(user, params) do
      user
      |> cast(params, [:is_blocked])  # Only allow :is_blocked to be updated
      |> validate_required([:is_blocked])  # Ensure :is_blocked is always present
    end

end
