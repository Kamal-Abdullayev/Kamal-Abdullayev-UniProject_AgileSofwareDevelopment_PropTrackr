defmodule ProptrackrWeb.Admin do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Proptrackr.Authentication.load_current_user(conn)
    if user && user.is_admin == true do
      conn
    else
      conn
      |> put_status(403)
      |> text("Forbidden")
      |> halt()
    end
  end

end
