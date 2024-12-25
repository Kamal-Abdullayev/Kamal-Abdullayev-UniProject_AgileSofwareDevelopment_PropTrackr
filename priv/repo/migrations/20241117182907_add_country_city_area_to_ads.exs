defmodule Proptrackr.Repo.Migrations.AddCountryCityAreaToAds do
  use Ecto.Migration

  def change do
    alter table(:advertisements) do
      add :country, :string
      add :city, :string
      add :area, :string
    end
  end
end
