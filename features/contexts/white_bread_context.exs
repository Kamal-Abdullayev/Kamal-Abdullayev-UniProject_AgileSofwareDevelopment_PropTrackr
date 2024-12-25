defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias Proptrackr.{Repo,Accounts.User, Ads.Advertisement}

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

  # Helper function to log in an existing user
  defp login_user do
    user_email = "example@example.com"
    # Fetch user with ID 82 (no dynamic creation)
    user = Repo.get!(User, 82)
    Accounts.login(user)
    user
  end

  # Helper function to login an existing user
  defp login_user do
    # Directly use the user with ID 82
    user = Repo.get!(User, 82)

    # Log the user in (assuming Accounts.login/1 exists)
    Accounts.login(user)
    user
  end



  # # Listing advertisements
  # when_ ~r/^I navigate to the advertisements page$/, fn state ->
  #   navigate_to("/advertisements")
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a list of advertisements$/, fn state ->
  #   assert visible_in_page? ~r/Listing Advertisements/
  #   {:ok, state}
  # end

  # # Creating a new advertisement (using data from the feature)
  # given_ ~r/^the following advertisements do not exist:$/, fn state, %{table_data: table} ->
  #   # Ensure the user with ID 82 is logged in
  #   user = login_user()

  #   # Add user_id to advertisement data
  #   new_ads = Enum.map(table, fn ad ->
  #     Map.put(ad, "user_id", user.id)
  #   end)
  #   {:ok, Map.put(state, :new_advertisement_data, new_ads)}
  # end

  # when_ ~r/^I navigate to the new advertisement form$/, fn state ->
  #   navigate_to("/advertisements/new")
  #   {:ok, state}
  # end

  # when_ ~r/^I fill in the advertisement form with valid data$/, fn state ->
  #   ad_data = hd(state[:new_advertisement_data])  # Get the first advertisement data

  #   fill_field({:id, "title"}, ad_data["title"])
  #   fill_field({:id, "description"}, ad_data["description"])
  #   fill_field({:id, "price"}, ad_data["price"])
  #   fill_field({:id, "square_meters"}, ad_data["square_meters"])
  #   fill_field({:id, "location"}, ad_data["location"])
  #   fill_field({:id, "rooms"}, ad_data["rooms"])
  #   fill_field({:id, "floor"}, ad_data["floor"])
  #   fill_field({:id, "total_floors"}, ad_data["total_floors"])

  #   {:ok, state}
  # end

  # when_ ~r/^I submit the form$/, fn state ->
  #   click({:id, "save_button"})
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a success message$/, fn state ->
  #   assert visible_in_page? ~r/Advertisement created successfully./
  #   {:ok, state}
  # end

  # given_ ~r/^there is an existing advertisement:$/, fn state, %{table_data: table} ->
  #   # Ensure the user with ID 82 is logged in
  #   user = login_user()

  #   inserted_ads =
  #     table
  #     |> Enum.map(fn ad ->
  #       changeset = Advertisement.changeset(%Advertisement{}, Map.put(ad, "user_id", user.id))
  #       inserted_ad = Repo.insert!(changeset)
  #       inserted_ad.id
  #     end)
  #   {:ok, Map.put(state, :ad_ids, inserted_ads)}
  # end

  # when_ ~r/^I navigate to the advertisement edit page$/, fn state ->
  #   ad_id = hd(state[:ad_ids])  # Use the inserted advertisement ID
  #   navigate_to("/advertisements/#{ad_id}/edit")
  #   {:ok, state}
  # end

  # when_ ~r/^I update the advertisement form with new data$/, fn state ->
  #   ad_data = hd(state[:ad_ids])  # Use the advertisement data

  #   fill_field({:id, "title"}, "Updated Villa Title")
  #   fill_field({:id, "description"}, "Updated description for the villa.")
  #   {:ok, state}
  # end

  # then_ ~r/^I should see an update success message$/, fn state ->
  #   assert visible_in_page? ~r/Advertisement updated successfully./
  #   {:ok, state}
  # end

  # # Deleting an advertisement (dynamically handling data)
  # given_ ~r/^there's an existing advertisement:$/, fn state, %{table_data: table} ->
  #   # Ensure the user with ID 82 is logged in
  #   user = login_user()

  #   inserted_ads =
  #     table
  #     |> Enum.map(fn ad_data ->
  #       changeset = Advertisement.changeset(%Advertisement{}, Map.put(ad_data, "user_id", user.id))
  #       inserted_ad = Repo.insert!(changeset)
  #       inserted_ad.id
  #     end)
  #   {:ok, Map.put(state, :advertisement_ids, inserted_ads)}
  # end

  # when_ ~r/^I delete the advertisement$/, fn state ->
  #   ad_id = hd(state[:advertisement_ids])  # Use the inserted advertisement ID
  #   navigate_to("/advertisements/#{ad_id}")
  #   click({:id, "delete_button"})
  #   accept_dialog() # Confirm the delete action
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a deletion success message$/, fn state ->
  #   assert visible_in_page? ~r/Advertisement deleted successfully./
  #   {:ok, state}
  # end

  # then_ ~r/^I should not see the advertisement in the list$/, fn state ->
  #   refute visible_in_page? ~r/Luxury Villa/
  #   {:ok, state}
  # end

  # # Handling users (example of handling user data)
  # # given_ ~r/^the following users exist:$/, fn state, %{table_data: table} ->
  # #   inserted_users =
  # #     table
  # #     |> Enum.map(fn user ->
  # #       changeset = User.changeset(%User{}, user)
  # #       inserted_user = Repo.insert!(changeset)
  # #       inserted_user.id
  # #     end)

  # #   {:ok, Map.put(state, :user_ids, inserted_users)}
  # # end

  # and_ ~r/^I visit edit profile page$/, fn state ->
  #   user_id = hd(state[:user_ids])  # Use the inserted user ID
  #   navigate_to "/users/#{user_id}/edit"
  #   {:ok, state}
  # end

  # and_ ~r/^I update my profile with new information$/, fn state ->
  #   fill_field({:id, "description"}, "New description")
  #   {:ok, state}
  # end

  # when_ ~r/^I submit profile information$/, fn state ->
  #   click({:id, "save_button"})
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a confirmation message$/, fn state ->
  #   assert visible_in_page? ~r/Profile updated successfully./
  #   {:ok, state}
  # end

  # and_ ~r/^I visit settings page$/, fn state ->
  #   user_id = hd(state[:user_ids])  # Use the inserted user ID
  #   navigate_to "/users/#{user_id}/settings"
  #   {:ok, state}
  # end

  # when_ ~r/^I choose to delete my account$/, fn state ->
  #   click({:id, "delete_account"})
  #   accept_dialog()
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a confirmation message of account deletion$/, fn state ->
  #   assert visible_in_page? ~r/Account deleted successfully./
  #   {:ok, state}
  # end

  # when_ ~r/^I open the home page$/, fn state ->
  #   navigate_to "/"
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a register-login button$/, fn state ->
  #   assert visible_in_page? ~r/Register/
  #   {:ok, state}
  # end

  # then_ ~r/^I should see a search form$/, fn state ->
  #   assert visible_in_page? ~r/Submit/
  #   {:ok, state}
  # end

  # given_ ~r/^I am on the home page$/, fn state ->
  #   navigate_to("/")
  #   {:ok, state}
  # end

  # when_ ~r/^I click the "Learn More" button for an advertisement$/, fn state ->
  #   navigate_to("/")
  #   # Based on id of the database this part have to be
  #   # click({:id, "ads-49"})
  #   {:ok, state}
  # end

  # then_ ~r/^I should see the detail page for that advertisement$/, fn state ->
  #   navigate_to("/advertisements/1")
  # end

  # given_ ~r/^the following advertisements exist for search:$/, fn state, %{table_data: table} ->
  #   inserted_ads =
  #     table
  #     |> Enum.map(fn ad ->
  #       changeset = Advertisement.changeset(%Advertisement{}, ad)
  #       Repo.insert!(changeset)
  #     end)
  #   {:ok, Map.put(state, :inserted_ads, inserted_ads)}
  # end

  # and_ ~r/^I visit search page$/, fn state ->
  #   navigate_to "/search"
  #   {:ok, state}
  # end

  # and_ ~r/^I select country$/, fn state ->
  #   fill_field({:id, "country"}, "Estonia")
  #   {:ok, state}
  # end

  # when_ ~r/^I submit search properties$/, fn state ->
  #   click({:id, "search_button"})
  #   {:ok, state}
  # end

  # then_ ~r/^I should not find results$/, fn state ->
  #   refute visible_in_page? ~r/Modern Apartment in Kesklinn/
  #   {:ok, state}
  # end

  # # View user profile from advertisement (new scenario)
  # given_ ~r/^the following advertisements exist:$/, fn state, %{table_data: table} ->
  #   # Ensure the user with ID 82 is logged in
  #   user = login_user()

  #   inserted_ads =
  #     table
  #     |> Enum.map(fn ad_data ->
  #       changeset = Advertisement.changeset(%Advertisement{}, Map.put(ad_data, "user_id", user.id))
  #       inserted_ad = Repo.insert!(changeset)
  #       inserted_ad.id
  #     end)
  #   {:ok, Map.put(state, :ad_ids, inserted_ads)}
  # end

  # when_ ~r/^I click the "View Profile" button for the advertisement$/, fn state ->
  #   ad_id = hd(state[:ad_ids])  # Use the inserted advertisement ID
  #   navigate_to("/advertisements/#{ad_id}")
  #   click({:id, "view_profile_button"})

  #   # Print out the page content for debugging
  #   IO.inspect(page_source())

  #   {:ok, state}
  # end


  # then_ ~r/^I should be redirected to the user's profile page$/, fn state ->
  #   # Assert the profile page contains user details
  #   assert visible_in_page? ~r/User Profile/
  #   {:ok, state}
  # end

  # then_ ~r/^I should see the user's advertisements on the profile page$/, fn state ->
  #   # Ensure the profile page contains the user's ads
  #   assert visible_in_page? ~r/Advertisements/
  #   {:ok, state}
  # end



end
