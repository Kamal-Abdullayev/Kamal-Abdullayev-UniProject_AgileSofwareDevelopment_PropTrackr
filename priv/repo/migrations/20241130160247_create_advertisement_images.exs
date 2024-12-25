defmodule YourApp.Repo.Migrations.CreateAdvertisementImages do
  use Ecto.Migration

  def change do
    create table(:advertisement_images) do
      add :advertisement_id, references(:advertisements, on_delete: :delete_all), null: false
      add :image_path, :string, null: false

      timestamps()
    end

    create index(:advertisement_images, [:advertisement_id])
  end
end
