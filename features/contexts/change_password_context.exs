defmodule ChangePasswordContext do
  use WhiteBread.Context
  alias Proptrackr.{Repo, Accounts.User}
  alias ProptrackrWeb.Router.Helpers, as: Routes
  alias Plug.Conn
  import Phoenix.ConnTest
  import Ecto.Query
  import Plug.Conn

  @endpoint ProptrackrWeb.Endpoint


  # Step: Create a user with the given email and password
  given_ ~r/^a user with email "(?<email>[^"]+)" and password "(?<password>[^"]+)" exists$/ do
    fn state, %{email: email, password: password} ->
      hashed_password = Bcrypt.hash_pwd_salt(password)

      user = %User{
        firstname: "John",
        lastname: "Doe",
        email: email,
        hashed_password: hashed_password
      }

      user = Repo.insert!(user)

      # Include the user in the state for later steps
      {:ok, Map.put(state, :user, user)}
    end
  end


  # Step: Log in as a user
  given_ ~r/^I am logged in as "(?<email>[^"]+)"$/ do
    fn %{conn: conn} = state, %{email: email} ->
      user = Repo.get_by!(User, email: email)

      conn = conn || build_conn()

      conn = conn
             |> init_test_session(%{})
             |> put_session(:user_id, user.id)

      # Update state with `conn` and keep `user` from prior step
      {:ok, Map.merge(state, %{conn: conn, user: user})}
    end
  end

  # Step: Change password
  when_ ~r/^I change my password with old password "(?<old_password>[^"]+)" and new password "(?<new_password>[^"]+)"$/ do
    fn %{conn: conn, user: user}, %{old_password: old_password, new_password: new_password} ->
      params = %{
        "old_password" => old_password,
        "password" => new_password,
        "password_confirmation" => new_password
      }

      conn =
        post(conn, Routes.user_path(@endpoint, :change_password, user.id), %{"user" => params})

      {:ok, %{conn: conn}}
    end
  end

  # Step: Check for confirmation message
  then_ ~r/^I should see a confirmation message "(?<message>[^"]+)"$/ do
    fn %{conn: conn}, %{message: message} ->
      # Retrieve the flash message from the connection
      actual_message = Phoenix.Controller.get_flash(conn, :info)

      # Assert the flash message matches the expected message
      assert actual_message == message

      :ok
    end
  end

  then_ ~r/^I should see an error message "(?<message>[^"]+)"$/ do
    fn %{conn: conn}, %{message: message} ->
      assert get_flash(conn, :error) == message
      :ok
    end
  end
  then_ ~r/^my password should be updated to "(?<new_password>[^"]+)"$/ do
    fn %{user: user}, %{new_password: new_password} ->
      updated_user = Repo.get(User, user.id)
      assert Bcrypt.verify_pass(new_password, updated_user.hashed_password)
      :ok
    end
  end
  then_ ~r/^my password should remain unchanged$/ do
    fn %{user: user} ->
      original_user = Repo.get(User, user.id)
      assert Bcrypt.verify_pass("valid_old_password", original_user.hashed_password)
      :ok
    end
  end


end
