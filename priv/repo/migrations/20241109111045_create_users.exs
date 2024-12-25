defmodule Proptrackr.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string, null: false
      add :lastname, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false
      add :birthdate, :date
      add :phone, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
    create unique_index(:users, [:email])
  end
end
