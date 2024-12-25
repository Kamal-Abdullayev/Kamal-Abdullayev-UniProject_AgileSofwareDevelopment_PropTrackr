 defmodule ProptrackrWeb.AdvertisementTest do
  use Proptrackr.DataCase, async: true
  alias Proptrackr.Ads
  alias Proptrackr.Ads.Advertisement

  # describe "get_recommended_properties/2" do
  #   setup do
  #     base_ad = %Advertisement{
  #       type: "Rent",
  #       price: Decimal.new(1200),
  #       rooms: 3,
  #       square_meters: 80,
  #       title: "Cozy apartment",
  #       description: "Close to downtown",
  #       city: "Test City",
  #       area: "Test Area"
  #     } |> Repo.insert!()

  #     recommended_ads = [
  #       %Advertisement{
  #         type: "Rent",
  #         price: Decimal.new(1180),
  #         rooms: 3,
  #         square_meters: 79,
  #         city: "Test City",
  #         area: "Nearby"
  #       },
  #       %Advertisement{
  #         type: "Rent",
  #         price: Decimal.new(1250),
  #         rooms: 3,
  #         square_meters: 82,
  #         city: "Test City2",
  #         area: "Nearby"
  #       },
  #       %Advertisement{
  #         type: "Rent",
  #         price: Decimal.new(1250),
  #         rooms: 3,
  #         square_meters: 82,
  #         city: "Test City3",
  #         area: "Nearby"
  #       },
  #       %Advertisement{
  #         type: "Rent",
  #         price: Decimal.new(1250),
  #         rooms: 3,
  #         square_meters: 82,
  #         city: "Test City4",
  #         area: "Nearby"
  #       },
  #       %Advertisement{
  #         type: "Rent",
  #         price: Decimal.new(1250),
  #         rooms: 3,
  #         square_meters: 82,
  #         city: "Test City5",
  #         area: "Nearby"
  #       }
  #     ] |> Enum.map(&Repo.insert!/1)

  #     # Insert non-recommended advertisements (not matching criteria)
  #     non_recommended_ads = [
  #       %Advertisement{type: "Sale", price: Decimal.new(200000), rooms: 4, square_meters: 120},
  #       %Advertisement{type: "Rent", price: Decimal.new(5000), rooms: 1, square_meters: 50}
  #     ] |> Enum.map(&Repo.insert!/1)

  #     {:ok, base_ad: base_ad, recommended_ads: recommended_ads, non_recommended_ads: non_recommended_ads}
  #   end

  #   test "returns only advertisements matching the criteria", %{base_ad: base_ad, recommended_ads: recommended_ads} do
  #     result = Ads.get_recommended_properties(base_ad)
  #     assert Enum.all?(recommended_ads, fn ad -> ad in result end)
  #     refute Enum.any?(result, fn ad -> ad.type != "Rent" or ad.price > Decimal.new(1300) end)
  #   end

  #   test "limits the number of recommendations", %{base_ad: base_ad} do
  #     result = Ads.get_recommended_properties(base_ad, 5)
  #     assert length(result) == 5
  #   end
  # end

  # test "GET /advertisements", %{conn: conn} do
  #   conn = get(conn, ~p"/")
  #   assert html_response(conn, 200) =~ "Listing Advertisements"
  # end

  # test "GET /advertisements", %{conn: conn} do
  #   conn = get(conn, ~p"/")
  #   assert html_response(conn, 200) =~ "Listing Advertisements"
  # end


end
