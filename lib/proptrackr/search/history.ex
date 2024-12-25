defmodule Proptrackr.Search.History do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_history" do
    field :keyword, :string

    belongs_to :user, Proptrackr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(history, attrs) do
    history
    |> cast(attrs, [:keyword])
    |> validate_required([:keyword])
  end
end
