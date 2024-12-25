defmodule Proptrackr.AdsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Proptrackr.Ads` context.
  """

  @doc """
  Generate a advertisement.
  """
  def advertisement_fixture(attrs \\ %{}) do
    {:ok, advertisement} =
      attrs
      |> Enum.into(%{
        description: "some description",
        floor: 42,
        images: [],
        location: "some location",
        price: "120.5",
        reference: "some reference",
        rooms: 42,
        square_meters: 42,
        state: "some state",
        title: "some title",
        total_floors: 42,
        type: "some type"
      })
      |> Proptrackr.Ads.create_advertisement()

    advertisement
  end


end
