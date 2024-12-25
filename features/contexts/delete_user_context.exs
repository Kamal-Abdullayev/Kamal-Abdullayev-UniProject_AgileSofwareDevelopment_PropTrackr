defmodule DeleteUserContext do
  use WhiteBread.Context
  use Hound.Helpers
  use Phoenix.ConnTest

  alias Proptrackr.{Repo,Accounts.User,Authentication}

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

  given_ ~r/^the following users exist:$/, fn state, %{table_data: table} ->
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
      password: "password123",
    })
    |> Repo.insert!()

    navigate_to "/sessions/new"
    fill_field({:id, "email"}, "test@example.com")
    fill_field({:id, "password"}, "password123")
    click({:id, "submit"})
    state = Map.put(state, :current_user, user)
    {:ok, state}
  end

  and_ ~r/^I am logged in as admin$/, fn state ->
    admin_user = Repo.insert!(%User{
      firstname: "Test",
      lastname: "User",
      email: "test@example.com",
      is_admin: true,
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })

    navigate_to "/sessions/new"
    fill_field({:id, "email"}, "test@example.com")
    fill_field({:id, "password"}, "password123")
    click({:id, "submit"})
    state = Map.put(state, :current_user, admin_user)
    {:ok, state}
  end

  and_ ~r/^I visit "(?<argument_one>[^"]+)" page$/, fn state, %{argument_one: page_name} ->
    # Determine the URL based on the page name
    current_user = state[:current_user]
    url =
      case page_name do
        "main" -> "/"
        "users" -> "/users"
        "edit" -> "/users/#{current_user.id}/edit"
        "settings" -> "/settings"
        "users/delete" -> "/users/#{hd(state[:user_ids])}/delete"
        _ -> "/"
      end

    conn = state[:conn]
    navigate_to(url, conn)
    {:ok, state}
  end

  and_ ~r/^I choose to delete my account$/, fn state ->
    click({:id, "delete_account"})
    {:ok, state}
  end
  when_ ~r/^I confirm deletion$/, fn state ->
    accept_dialog()
    {:ok, state}
  end

  and_ ~r/^I click delete$/, fn state ->
    inserted_user = state[:user_ids]
    user = hd(inserted_user)
    click({:id, "delete-user-#{user}"})
    accept_dialog()
    {:ok, state}
  end

  when_ ~r/^I cancel deletion$/, fn state ->
    dismiss_dialog()
    {:ok, state}
  end

  then_ ~r/^I should see a confirmation message of account deletion$/, fn state ->
    assert visible_in_page? ~r/Account deleted successfully./
    {:ok, state}
  end

  then_ ~r/^I should still be on settings page$/, fn state ->
    assert visible_in_page? ~r/Settings/
    {:ok, state}
  end

  then_ ~r/^I should not have access$/, fn state ->
    refute visible_in_page? ~r/Listing users/
    {:ok, state}
  end

end
