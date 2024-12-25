defmodule Proptrackr.Repo.Migrations.AddPhotoPathsToAdvertisements do
  use Ecto.Migration

  def change do
    alter table(:advertisements) do
      add :photo_paths, {:array, :string}, default: []
    end
  end
end
