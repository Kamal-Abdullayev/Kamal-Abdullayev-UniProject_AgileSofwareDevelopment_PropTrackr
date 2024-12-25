defmodule ProptrackrWeb.UserController do
  use ProptrackrWeb, :controller
  alias Proptrackr.{Repo, Authentication, Accounts.User}

  # Show user profile (public view for any user)
  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id) |> Repo.preload(:ads)

    # Check if the user has no ads
    if Enum.empty?(user.ads) do
      # If the user has no ads, redirect or show a not found message
      conn
      |> put_flash(:error, "No ads found for this user.")
      |> redirect(to: "/")  # Redirect to home page or another relevant page
    else
      render(conn, "show.html", user: user)
    end
  end


  def change_password_forum(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    # Create an empty changeset (no password params yet)
    changeset = User.changeset(user, %{}, false) # false because we don't want to validate the password initially
    render(conn, "change_password.html", user: user, changeset: changeset)
  end

  def change_password(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)

    # Create the changeset for the password change logic
    changeset = Proptrackr.Accounts.User.change_password_changeset(user, user_params)

    # Attempt to update the password
    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: ~p"/settings")

      {:error, changeset} ->
        # If there is an error, return the user and changeset to the form
        conn
        |> put_flash(:error, "There was an error updating your password.")
        |> render("change_password.html", user: user, changeset: changeset)
    end
  end

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def settings(conn, _params) do
    auth_user = Authentication.load_current_user(conn)
    user = Repo.get!(User, auth_user.id)
    render(conn, "settings.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    # Retrieve the user data from the database
    auth_user = Authentication.load_current_user(conn)
    user = Repo.get!(User, id)

    cond do
      # Regular user editing their own profile
      auth_user.id == user.id ->
        changeset = User.changeset(user, %{})
        render(conn, "edit.html", user: user, changeset: changeset)

      # Admin editing another user's profile
      auth_user.is_admin ->
        changeset = User.changeset(user, %{})
        render(conn, "edit.html", user: user, changeset: changeset)

      # Unauthorized access
      true ->
        conn
        |> put_flash(:error, "Page not allowed!")
        |> redirect(to: ~p"/")
    end
  end


  def admin_edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, %{})
    render(conn, "admin_edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    # Retrieve the data of the user
    user = Repo.get!(User, id)
    auth_user = Authentication.load_current_user(conn)

    cond do
      # Regular user updating their own profile
      user.id == auth_user.id ->
        changeset = User.changeset(user, user_params, false)

        case Repo.update(changeset) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Profile updated successfully.")
            |> redirect(to: ~p"/settings")
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end

      # Admin updating any user's profile
      auth_user.is_admin ->
        changeset = User.changeset(user, user_params, false)

        case Repo.update(changeset) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: ~p"/users")
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end

      # Unauthorized access
      true ->
        conn
        |> put_flash(:error, "Page not allowed!")
        |> redirect(to: ~p"/")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    auth_user = Authentication.load_current_user(conn)
    cond do
      # Regular user updating their own profile
      user.id == auth_user.id ->
        Repo.delete!(user)
        conn
        |> put_flash(:info, "Account deleted successfully.")
        |> redirect(to: ~p"/")
      auth_user.is_admin ->
        Repo.delete!(user)
        conn
        |> put_flash(:info, "Account deleted successfully.")
        |> redirect(to: ~p"/users")
      true ->
          conn
          |> put_flash(:error, "Page not allowed!")
          |> redirect(to: ~p"/")
      end
  end

  def block(conn, %{"id" => id}) do
    user =  Repo.get!(User, id)

    new_status = !user.is_blocked
    changeset = User.block_changeset(user, %{is_blocked: new_status})

    case Repo.update(changeset) do
      {:ok, _user} ->
        status_message = if new_status, do: "User is now blocked.", else: "User is now unblocked."

        conn
        |> put_flash(:info, status_message)
        |> redirect(to: ~p"/users")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Unable to update user block status.")
        |> redirect(to: ~p"/users")
    end
  end

end
