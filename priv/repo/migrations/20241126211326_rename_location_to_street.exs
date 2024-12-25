defmodule YourApp.Repo.Migrations.RenameLocationToStreet do
  use Ecto.Migration

  def change do
    rename table(:advertisements), :location, to: :street
  end
end
