defmodule Proptrackr.Repo.Migrations.CreateAdvertisements do
  use Ecto.Migration

  def change do
    create table(:advertisements) do
      add :title, :string
      add :description, :text
      add :price, :decimal
      add :images, {:array, :binary}
      add :type, :string
      add :square_meters, :integer
      add :location, :string
      add :rooms, :integer
      add :floor, :integer
      add :total_floors, :integer
      add :reference, :string
      add :state, :string

      timestamps(type: :utc_datetime)
    end
  end
end
