defmodule PastSearchContext do
  use WhiteBread.Context

  use Hound.Helpers
  alias Proptrackr.{Repo, Accounts.User}


  feature_starting_state fn  ->
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

  when_ ~r/^I am logged in$/, fn state ->
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

  and_ ~r/^I am on the home page$/, fn state ->
    navigate_to "/"
    {:ok, state}
  end


  when_ ~r/^I open enter the search keyword "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: argument_one} ->
    navigate_to "/"
    fill_field({:id, "keyword"}, argument_one)
    click({:id, "submit"})
    {:ok, state}
  end

  then_ ~r/^I should see the random in the recent searches list$/,
  fn state ->
    navigate_to "/"
    assert visible_in_page? ~r/random/
    {:ok, state}
  end

end
