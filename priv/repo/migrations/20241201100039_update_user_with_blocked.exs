defmodule Proptrackr.Repo.Migrations.UpdateUserWithBlocked do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_blocked, :boolean, default: false
    end
  end
end
