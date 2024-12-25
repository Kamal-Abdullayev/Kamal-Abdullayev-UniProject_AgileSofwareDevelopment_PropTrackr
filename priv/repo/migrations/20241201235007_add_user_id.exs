defmodule Proptrackr.Repo.Migrations.AddUserId do
  use Ecto.Migration

  def change do
    alter table(:search_history) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
