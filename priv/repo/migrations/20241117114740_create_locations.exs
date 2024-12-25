defmodule Proptrackr.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :country, :string, null: false
      add :city, :string, null: false
      add :area, :string, null: false
    end

  end
end
