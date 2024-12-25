defmodule Proptrackr.Repo.Migrations.UpdateUserWithIsAdmin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_admin, :boolean, default: false
      remove :role
    end
  end
end
