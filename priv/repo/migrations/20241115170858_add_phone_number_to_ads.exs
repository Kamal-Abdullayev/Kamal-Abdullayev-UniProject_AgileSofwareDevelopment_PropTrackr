defmodule Proptrackr.Repo.Migrations.AddPhoneNumberToAds do
  use Ecto.Migration

  def change do
    alter table(:advertisements) do
      add :phone_number, :string
    end
  end
end
