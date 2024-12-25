defmodule HomePageContext do
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

  when_ ~r/^I open the app$/, fn state ->
     navigate_to "/"
     {:ok, state}
   end

  then_ ~r/^I should see a register-login button$/, fn state ->
    assert visible_in_page? ~r/Log in/
    assert visible_in_page? ~r/Register/
    {:ok, state}
  end

  then_ ~r/^I should see a search form$/, fn state ->
    assert visible_in_page? ~r/Submit/
    {:ok, state}
  end

end
