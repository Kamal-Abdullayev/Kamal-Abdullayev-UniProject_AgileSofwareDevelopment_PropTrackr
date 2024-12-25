defmodule Proptrackr.Repo.Migrations.AddUserIdToAdvertisements do
  use Ecto.Migration

  def change do
    alter table(:advertisements) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
