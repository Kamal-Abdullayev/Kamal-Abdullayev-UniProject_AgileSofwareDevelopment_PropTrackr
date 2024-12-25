defmodule ProptrackrWeb.BlockUserTest do
  use ProptrackrWeb.ConnCase
  alias Proptrackr.{Repo,Authentication,Accounts.User}
  setup do
    # admin user
    admin_user = Repo.insert!(%User{
      firstname: "Test",
      lastname: "User",
      email: "test@example.com",
      is_admin: true,
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })

    regular_user = Repo.insert!(%User{
      firstname: "Regular",
      lastname: "User",
      email: "regular@example.com",
      is_admin: false,
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })
    #User to be blocked
    block_user = Repo.insert!(%User{
      firstname: "Block",
      lastname: "User",
      email: "block@example.com",
      is_admin: false,
      is_blocked: false,
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })

    # Return the inserted users in the setup context
    {:ok, admin: admin_user, block_user: block_user, regular_user: regular_user}
  end

  test "Admin successfully blocks user", %{conn: conn, admin: admin_user, block_user: block_user} do
    # Assertions using admin and block_user
    assert admin_user.is_admin == true
    assert block_user.is_admin == false

    {:ok, _} = Proptrackr.Authentication.check_credentials(admin_user, "password123")
    conn = Proptrackr.Authentication.login(conn, admin_user)

    # Blocking user
    params = %{
      "is_blocked" => true
    }
    conn = patch(conn, ~p"/users/#{block_user.id}/block", params)

    blocked_user = Repo.get!(User, block_user.id)
    assert blocked_user.is_blocked == true

  end

  test "Non-admin unable to block user", %{conn: conn, regular_user: regular_user, block_user: block_user} do
    # Assertions using admin and block_user
    assert regular_user.is_admin == false
    assert block_user.is_admin == false

    {:ok, _} = Proptrackr.Authentication.check_credentials(regular_user, "password123")
    conn = Proptrackr.Authentication.login(conn, regular_user)

    # Blocking user
    params = %{
      "is_blocked" => true
    }
    conn = patch(conn, ~p"/users/#{block_user.id}/block", params)

    blocked_user = Repo.get!(User, block_user.id)
    assert blocked_user.is_blocked == false

  end


end
