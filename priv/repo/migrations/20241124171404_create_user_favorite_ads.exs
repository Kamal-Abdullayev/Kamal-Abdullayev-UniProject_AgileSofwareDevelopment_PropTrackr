defmodule Proptrackr.Repo.Migrations.CreateUserFavoriteAds do
  use Ecto.Migration

  def change do
    create table(:user_favorite_ads) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :advertisement_id, references(:advertisements, on_delete: :delete_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_favorite_ads, [:user_id, :advertisement_id])
  end
end
