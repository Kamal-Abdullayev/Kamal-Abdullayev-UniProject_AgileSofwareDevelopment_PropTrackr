defmodule ProptrackrWeb.SessionController do
  use ProptrackrWeb, :controller

  alias Proptrackr.{Repo, Authentication, Accounts.User}

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: email)
    case Authentication.check_credentials(user, password) do
      {:ok, _} ->
        conn
        |> Authentication.login(user)
        |> put_flash(:info, "Welcome #{user.firstname}!")
        |> redirect(to: ~p"/")
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Bad User Credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.logout
    |> redirect(to: ~p"/sessions/new")
  end

  def register(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "register.html", changeset: changeset)
  end

  def registerUser(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
          |> put_flash(:info, "User created successfully.")
          |> redirect(to: ~p"/")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

end
