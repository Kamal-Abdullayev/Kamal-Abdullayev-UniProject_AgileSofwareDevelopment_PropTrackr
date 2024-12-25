defmodule Proptrackr.Repo.Migrations.CreateSearchHistory do
  use Ecto.Migration

  def change do
    create table(:search_history) do
      add :keyword, :string

      timestamps(type: :utc_datetime)
    end
  end
end
