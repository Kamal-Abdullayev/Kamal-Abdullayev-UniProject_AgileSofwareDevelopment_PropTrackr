defmodule AdvertisementContext do
  use WhiteBread.Context
  use Hound.Helpers


  alias Proptrackr.{Repo,Accounts.User, Ads.Advertisement,Authentication,Locations.Location}


  # Shared state for tests
  # @shared %{}

  feature_starting_state fn ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Proptrackr.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Proptrackr.Repo, {:shared, self()})
    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Proptrackr.Repo)
    Hound.end_session
  end

  def select({strategy, locator}, value) do
    element = find_element(strategy, locator)
    click(element)
    option = find_within_element(element, :xpath, ".//option[@value='#{value}']")
    click(option)
  end



  # Given step: Create a base advertisement
  given_ ~r/^there is an advertisement with type "(?<type>[^"]+)" priced at "(?<price>\d+)" having "(?<rooms>\d+)" rooms and "(?<square_meters>\d+)" square meters$/ do
    fn %{type: type, price: price, rooms: rooms, square_meters: square_meters}, state ->
      ad = %Advertisement{
        type: type,
        price: Decimal.new(price),
        rooms: String.to_integer(rooms),
        square_meters: String.to_integer(square_meters),
        title: "Base Advertisement"
      }
      |> Repo.insert!()

      {:ok, Map.put(state, :base_ad, ad)}
    end
  end

  # Given step: Create recommended advertisements
given_ ~r/^there are similar advertisements available$/ do
  fn state ->
    base_ad = state.base_ad

    similar_ads = [
      %Advertisement{
        title: "Similar ad1",
        type: base_ad.type,
        price: Decimal.new(1180),
        rooms: base_ad.rooms,
        square_meters: base_ad.square_meters - 1
      },
      %Advertisement{
        title: "Similar ad2",
        type: base_ad.type,
        price: Decimal.new(1250),
        rooms: base_ad.rooms,
        square_meters: base_ad.square_meters + 2
      }
    ]

    Enum.each(similar_ads, &Repo.insert!/1)

    {:ok, state}
  end
end

# When step: Simulate viewing the advertisement detail page
when_ ~r/^I view the advertisement detail page$/ do
  fn state ->
    base_ad = state[:base_ad]

    # Fetch recommended ads, or use an empty list if the result is nil
    recommended_ads =
      case Ads.get_recommended_properties(base_ad) do
        nil -> []
        ads -> ads
      end

    # Navigating to the advertisement detail page
    navigate_to "/advertisements/#{base_ad.id}"

    # Store the recommended_ads in state
    {:ok, Map.put(state, :recommended_ads, recommended_ads)}
  end
end

# Then step: Verify advertisement details
then_ ~r/^I should see the advertisement details$/ do
  fn state ->
    assert state.base_ad.title == "Base Advertisement"
    :ok
  end
end

# Then step: Verify recommended advertisements
then_ ~r/^I should see up to "(?<limit>\d+)" recommended advertisements$/ do
  fn state, %{limit: limit} ->
    assert visible_in_page? ~r/Similar ad2/
    recommended_ads = state[:recommended_ads]
    assert length(recommended_ads || []) <= String.to_integer(limit)
    {:ok, state}
  end
end

then_ ~r/^I should see no recommended advertisements$/ do
  fn state ->
    # Check if recommended_ads is an empty list
    assert state[:recommended_ads] == []
    {:ok, state}
  end
end

## CREATING A NEW ADVERTISEMENT

given_ ~r/^the following users exist:$/, fn state, %{table_data: table} ->
  inserted_users =
    table
    |> Enum.map(fn user ->
      changeset = User.changeset(%User{}, user)
      inserted_user = Repo.insert!(changeset)
      inserted_user
    end)

  # Put inserted users in state so we can access them in later steps
  {:ok, Map.put(state, :inserted_users, inserted_users)}
end

and_ ~r/^I am logged in$/, fn state ->
  user = %User{}
  |> User.changeset(%{
    firstname: "Name",
    lastname: "Lastname",
    email: "test@example.com",
    password: "password123"
  })
  |> Repo.insert!()

  navigate_to "/sessions/new"
  fill_field({:id, "email"}, "test@example.com")
  fill_field({:id, "password"}, "password123")
  click({:id, "submit"})
  state = Map.put(state, :current_user, user)
  {:ok, state}
end

and_ ~r/^I navigate to the new advertisement form$/, fn state ->
  navigate_to "/advertisements/new"
  {:ok, state}
end

and_ ~r/^the following locations exist:$/, fn state, %{table_data: table_data} ->
  # Insert locations into the database
  Enum.each(table_data, fn location_data ->
    case Repo.get_by(Location, location_data) do
      nil ->
        %Location{}
        |> Location.changeset(location_data)
        |> Repo.insert!()

      _existing_location ->
        IO.puts("Skipped (already exists): #{inspect(location_data)}")
    end
  end)

  areas = Enum.map(table_data, fn %{area: area} -> area end)
  updated_state = Map.put(state, :areas, areas)

  {:ok, updated_state}
end

and_ ~r/^I fill in the advertisement form with:$/, fn state, %{table_data: table_data} ->

  ad_data = Enum.at(table_data, 0)

  # Use atoms to access map keys
  fill_field({:id, "title"}, Map.get(ad_data, :title, ""))
  fill_field({:id, "description"}, Map.get(ad_data, :description, ""))
  fill_field({:id, "price"}, Map.get(ad_data, :price, ""))
  fill_field({:id, "square_meters"}, Map.get(ad_data, :square_meters, ""))
  fill_field({:id, "rooms"}, Map.get(ad_data, :rooms, ""))
  fill_field({:id, "floor"}, Map.get(ad_data, :floor, ""))
  fill_field({:id, "total_floors"}, Map.get(ad_data, :total_floors, ""))
  fill_field({:id, "phone_number"}, Map.get(ad_data, :phone_number, ""))
  fill_field({:id, "street"}, Map.get(ad_data, :street, ""))
  select({:id, "country"}, "Estonia")
  select({:id, "area"}, "Kesklinn")
  select({:id, "city"}, "Tartu")
  select({:id, "state"}, "Available")
  select({:id, "type"}, "Rent")
  {:ok, Map.put(state, :ad_data, ad_data)}
  end

and_ ~r/^I submit the form.$/, fn state ->
  click({:id, "save_button"})

  {:ok, state}
end

then_ ~r/^I should see a success message$/, fn state ->
  assert visible_in_page? ~r/Advertisement created successfully./
  {:ok, state}
end


## LISTING ADVERTISEMENTS

when_ ~r/^I navigate to the advertisements page$/, fn state ->
  navigate_to "/advertisements"
  {:ok, state}
end


then_ ~r/^I should see the advertisement in the list$/, fn state ->
  assert visible_in_page? ~r/Cozy Apartment/
  {:ok, state}
end





and_ ~r/^there is an existing advertisement$/, fn state ->
  ad = %Advertisement{
    title: "Cozy Apartment",
    description: "Spacious 2-bedroom",
    price: Decimal.new(1200),
    square_meters: 80,
    rooms: 2,
    floor: 3,
    total_floors: 5,
    phone_number: "+372 2222 2222",
    country: "Estonia",
    city: "Tartu",
    area: "Kesklinn",
    street: "Raatuse",
    state: "Available",
    user_id: state[:current_user].id
  }
  |> Repo.insert!()

  {:ok, Map.put(state, :base_ad, ad)}
end


when_ ~r/^I navigate to the advertisement edit page$/, fn state ->
  navigate_to "/advertisements/#{state.base_ad.id}/edit"
  {:ok, state}
end


and_ ~r/^I update the advertisement form with new data$/, fn state ->
  fill_field({:id, "title"}, "Updated Cozy Apartment")
  {:ok, state}
end


and_ ~r/^I submit the form$/, fn state ->
  click({:id, "save_button"})
  {:ok, state}
end


then_ ~r/^I should see an update success message$/, fn state ->
  assert visible_in_page? ~r/Advertisement updated successfully./
  {:ok, state}
end


## DELETING AN ADVERTISEMENT


when_ ~r/^I delete the advertisement$/, fn state ->
  navigate_to "/advertisements"
  click({:id, "delete_button"})
  accept_dialog()
  {:ok, state}
end

when_ ~r/^I navigate to edit advertisement$/, fn state ->
  navigate_to "/advertisements/#{state[:base_ad].id}/edit"
  {:ok, state}
end


then_ ~r/^I should see a deletion success message$/, fn state ->
  assert visible_in_page? ~r/Advertisement deleted successfully./
  {:ok, state}
end


and_ ~r/^I should not see the advertisement in the list$/, fn state ->
  navigate_to "/advertisements"
  refute visible_in_page? ~r/Cozy Apartment/
  {:ok, state}
end



## UPDATING THE STATE OF AN ADVERTISEMENT

given_ ~r/^there is an advertisement with title "(?<title>[^"]+)" and initial state "(?<state>[^"]+)"$/, fn %{title: title, state: state}, test_state ->
  ad = %Advertisement{
    title: "Cozy Cottage in Annelinn",
    description: "A charming 3-bedroom cottage with a peaceful environment.",
    price: Decimal.new(900),
    square_meters: 85,
    rooms: 3,
    floor: 1,
    total_floors: 1,
    phone_number: "372 0000 2222",
    street: "Kaunase",
    state: state,
    country: "Estonia",
    city: "Tartu",
    area: "Annelinn",
    user_id: 1
  }
  |> Repo.insert!()

  {:ok, Map.put(test_state, :base_ad, ad)}
end

when_ ~r/^I navigate to the advertisement edit page to change state$/, fn test_state ->
  navigate_to "/advertisements/#{test_state[:base_ad].id}/edit"
  {:ok, test_state}
end

and_ ~r/^I update the state to reserved$/, fn test_state ->
  select({:id, "state"}, "Reserved")
  {:ok, test_state}
end


then_ ~r/^I should see a state update success message$/, fn test_state ->
  assert visible_in_page? ~r/Advertisement updated successfully./
  {:ok, test_state}
end

then_ ~r/^I should be able to click on recommended price button$/, fn state ->
  click({:id, "get-recommended-price"})
  {:ok, state}
end


end
