defmodule FavoriteContext do
  use WhiteBread.Context
  use Hound.Helpers
  use Phoenix.ConnTest

  alias Proptrackr.{Repo,Accounts.User, Ads.Advertisement,Authentication}

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

  and_ ~r/^the following advertisements exist:$/, fn state, %{table_data: table} ->
    user_ids = Map.get(state, :user_ids)
    inserted_ads =
      table
      |> Enum.map(fn ad ->
        ad = Map.update!(ad, :user_id, fn _ -> Enum.random(user_ids) end)
        changeset = Advertisement.changeset(%Advertisement{}, ad)
        Repo.insert!(changeset)
      end)

    {:ok, Map.put(state, :inserted_ads, inserted_ads)}
  end

  given_ ~r/^following users exist:$/, fn state, %{table_data: table} ->
    inserted_users =
      table
      |> Enum.map(fn user ->
        changeset = User.changeset(%User{}, user)
        inserted_user = Repo.insert!(changeset)
        inserted_user.id
      end)

    {:ok, Map.put(state, :user_ids, inserted_users)}
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

  and_ ~r/^I visit "(?<argument_one>[^"]+)" page$/, fn state, %{argument_one: page_name} ->
    # Determine the URL based on the page name
    current_user = state[:current_user]
    url =
      case page_name do
        "main" -> "/"
        "favorite" -> "/users/#{current_user.id}/favorite_ads"
        _ -> "/"
      end

    conn = state[:conn]
    navigate_to(url, conn)
    {:ok, state}
  end

  when_ ~r/^I click on add to favorite twice$/, fn state ->
    conn = state[:conn]
    inserted_ads = state[:inserted_ads]
    ad = hd(inserted_ads)
    click({:id, "ads-favorite-#{ad.id}"})
    assert visible_in_page? ~r/Advertisement added to your favorites./
    click({:id, "ads-favorite-#{ad.id}"})
    {:ok, state}
  end

  when_ ~r/^I click on add to favorite$/, fn state ->
    conn = state[:conn]
    inserted_ads = state[:inserted_ads]
    ad = hd(inserted_ads)
    click({:id, "ads-favorite-#{ad.id}"})
    updated_state = Map.put(state, :favorite_ad, ad)
    {:ok, updated_state}
  end

  then_ ~r/^I should see a confirmation message for added to favorites$/, fn state ->
    assert visible_in_page? ~r/Advertisement added to your favorites./
    {:ok, state}
  end

  then_ ~r/^I should see a confirmation message for removed from favorites$/, fn state ->
    assert visible_in_page? ~r/Advertisement removed from your favorites./
    {:ok, state}
  end

  and_ ~r/^I should not see favorites button$/, fn state ->
    conn = state[:conn]
    inserted_ads = state[:inserted_ads]
    ad = hd(inserted_ads)
    refute visible_in_page? ~r/ads-favorite-#{ad.id}/
    {:ok, state}
  end

  then_ ~r/^I should see favorite ad$/, fn state ->
    favorite_ad = state[:favorite_ad]
    assert visible_in_page? ~r/#{favorite_ad.title}/
    {:ok, state}
  end

end
