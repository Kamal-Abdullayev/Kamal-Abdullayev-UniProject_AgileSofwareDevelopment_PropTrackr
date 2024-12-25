defmodule Proptrackr.Repo.Migrations.AddPhotoPathToProducts do
  use Ecto.Migration

  def change do
    alter table(:advertisements) do
      add :photo_path, :string
    end
  end
end
