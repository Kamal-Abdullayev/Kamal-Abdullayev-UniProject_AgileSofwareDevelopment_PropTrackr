defmodule Proptrackr.Repo.Migrations.UserNotInterestingAds do
  use Ecto.Migration

  def change do
    create table(:user_not_interesting_ads) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :advertisement_id, references(:advertisements, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
    create unique_index(:user_not_interesting_ads, [:user_id, :advertisement_id])

  end
end
