defmodule AuthContext do
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

  when_ ~r/^I visit the main page$/, fn state ->
    navigate_to "/"
    {:ok, state}
  end

  and_ ~r/^I visit the login page$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^I visit the register page$/, fn state ->
    navigate_to "/register"
    {:ok, state}
  end

  and_ ~r/^I entered the correct details$/, fn state ->
    inserted_users = Map.get(state, :inserted_users)
    user_to_login = hd(inserted_users)

    fill_field({:id, "email"}, user_to_login.email)
    fill_field({:id, "password"}, user_to_login.password)
    {:ok, state}
  end

  and_ ~r/^I entered wrong password "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    inserted_users = Map.get(state, :inserted_users)
    user_to_login = hd(inserted_users)

    fill_field({:id, "email"}, user_to_login.email)

    fill_field({:id, "password"}, _argument_one)
    {:ok, state}
  end

  when_ ~r/^I submit the login form$/, fn state ->
    click({:id, "submit"})
    {:ok, state}
  end

  then_ ~r/^I should see the welcome message$/,fn state ->
    Process.sleep(2000)
    assert visible_in_page? ~r/Welcome Tiiu!/
    {:ok, state}
  end

  then_ ~r/^I should see error message$/, fn state ->
    assert visible_in_page? ~r/Bad User Credentials/
    {:ok, state}
  end


  and_ ~r/^I entered the email "(?<argument_one>[^"]+)", password "(?<argument_two>[^"]+)", firstname "(?<argument_three>[^"]+)", lastname "(?<argument_four>[^"]+)"$/, fn state, %{argument_one: _argument_one, argument_two: _argument_two, argument_three: _argument_three, argument_four: _argument_four} ->
    fill_field({:id, "email"}, _argument_one)
    fill_field({:id, "password"}, _argument_two)
    fill_field({:id, "firstname"}, _argument_three)
    fill_field({:id, "lastname"}, _argument_four)
    {:ok, state}
  end

  and_ ~r/^I submit the register form$/, fn state ->
    click({:id, "register"})
    {:ok, state}
  end

  then_ ~r/^I should see confirmation message$/, fn state ->
    assert visible_in_page? ~r/User created successfully./
    {:ok, state}
  end

  then_ ~r/^I should see cant be blank message$/, fn state ->
    assert visible_in_page? ~r/can't be blank/
    {:ok, state}
  end

  when_ ~r/^I log out$/, fn state ->
    navigate_to "/"
    click({:id, "logout"})
    {:ok, state}
  end

  then_ ~r/^I should be logged out$/, fn state ->
    assert visible_in_page? ~r/Log in/
    refute visible_in_page? ~r/Log out/
    {:ok, state}
  end

  then_ ~r/^I should not see log out button$/, fn state ->
    refute visible_in_page? ~r/Log out/
    {:ok, state}
  end

end
