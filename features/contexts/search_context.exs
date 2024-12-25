defmodule SearchContext do
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

  and_ ~r/^there is an existing available advertisement$/, fn state ->
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
      user_id: hd(state[:inserted_users]).id
    }
    |> Repo.insert!()

    ad2 = %Advertisement{
      title: "Filter ad",
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
      type: "Rent",
      user_id: hd(state[:inserted_users]).id
    }
    |> Repo.insert!()
    updated_state = Map.put(state, :base_ad, ad)
    updated_state =  Map.put(updated_state, :filter_ad, ad2)
    {:ok, updated_state}
  end

  when_ ~r/^I am on main page$/, fn state ->
    navigate_to "/"
    {:ok, state}
  end

  then_ ~r/^I should see this ad$/, fn state ->
    assert visible_in_page? ~r/Cozy Apartment/
    {:ok, state}
  end

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

  when_ ~r/^I am on search page$/, fn state ->
    navigate_to "/search?search="
    {:ok, state}
  end

  then_ ~r/^I can select type$/, fn state ->
    select({:id, "type"}, "Rent")
    {:ok, state}
  end

  and_ ~r/^I can select country$/, fn state ->
    select({:id, "country"}, "Estonia")
    {:ok, state}
  end

  and_ ~r/^I submit search$/, fn state ->
    click({:id, "search_button"})
    {:ok, state}
  end

  then_ ~r/^I should see the advertisement$/, fn state ->
    assert visible_in_page? ~r/Filter ad/
    {:ok, state}
  end

  then_ ~r/^I can choose price, number of rooms and city areas$/, fn state ->
    assert visible_in_page? ~r/Minimum Price/
    assert visible_in_page? ~r/Maximum Price/
    assert visible_in_page? ~r/Maximum rooms/
    assert visible_in_page? ~r/Minimum rooms/
    assert visible_in_page? ~r/City/
    assert visible_in_page? ~r/Area/
    {:ok, state}
  end


end
