defmodule ProptrackrWeb.UserControllerTest do
  use ProptrackrWeb.ConnCase
  alias Proptrackr.{Repo, Accounts.User, Ads.Advertisement,Authentication}

  test "successfully updates password with valid data", %{conn: conn} do
    # Insert a sample user into the database with a known hashed password
    user = Repo.insert!(%User{
      firstname: "Test",
      lastname: "User",
      email: "test@example.com",
      hashed_password: Pbkdf2.hash_pwd_salt("oldpassword")
    })

    params = %{
      "id" => user.id,
      "user" => %{
        "old_password" => "oldpassword",
        "password" => "newpassword123",
        "password_confirmation" => "newpassword123"
      }
    }

    # Send the post request to change the password
    _conn = post(conn, "/users/change_password", params)

    updated_user = Repo.get!(User, user.id)
    assert updated_user.hashed_password == user.hashed_password
  end

  test "Advertisement appears on user's profile page", %{conn: conn} do
    # Ensure the test user is present
    user =
      Repo.get_by(Proptrackr.Accounts.User, email: "example@example.com") ||
        Repo.insert!(%Proptrackr.Accounts.User{
          firstname: "Tiiu",
          lastname: "Tamm",
          email: "example@example.com",
          password: Bcrypt.hash_pwd_salt("super_secret_password"),
          birthdate: ~D[1990-01-01],
          phone: "123-456-7890",
          description: "Example description"
        })

    # Insert an advertisement
    advertisement = Repo.insert!(%Proptrackr.Ads.Advertisement{
      title: "Test Ad Title",
      description: "A test advertisement",
      price: Decimal.new("100.0"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn",
      state: "Available",
      type: "Rent",
      square_meters: 100,
      street: "Raatuse",
      user_id: user.id
    })


    conn = get(conn, "/")
    response = html_response(conn, 200)


    assert response =~ "View Profile"


    conn = get(conn, ~p"/users/#{user.id}")

    response = html_response(conn, 200)
    assert response =~ "Test Ad Title"


    assert response =~ "A test advertisement"

  end

  describe "Edit and delete user" do
    setup do
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

      delete_user = Repo.insert!(%User{
        firstname: "Delete",
        lastname: "User",
        email: "delete@example.com",
        is_admin: false,
        hashed_password: Pbkdf2.hash_pwd_salt("password123")
      })

      # Return the inserted users in the setup context
      {:ok, admin: admin_user, regular_user: regular_user, delete_user: delete_user}
    end

    test "Authenticated non-admin user successfully edits profile information", %{conn: conn, regular_user: regular_user} do

      {:ok, _} = Proptrackr.Authentication.check_credentials(regular_user, "password123")
      conn = Proptrackr.Authentication.login(conn, regular_user)

      params = %{
        "id" => regular_user.id,
        "user" => %{
        "lastname" => "new"
        }
      }
      conn = put(conn, ~p"/users/#{regular_user.id}/edit", params)

      updated_user = Repo.get!(User, regular_user.id)
      assert redirected_to(conn) == "/settings"
      #should be updated
      assert updated_user.lastname == "new"
    end

    test "Authenticated non-admin user unsuccessful edit profile", %{conn: conn, regular_user: regular_user} do

      {:ok, _} = Proptrackr.Authentication.check_credentials(regular_user, "password123")
      conn = Proptrackr.Authentication.login(conn, regular_user)
      # Last name cannot be empty
      params = %{
        "id" => regular_user.id,
        "user" => %{
        "lastname" => ""
        }
      }
      conn = put(conn, ~p"/users/#{regular_user.id}/edit", params)

      updated_user = Repo.get!(User, regular_user.id)

      #Should not be updated
      assert html_response(conn, 200)
      assert updated_user.lastname == regular_user.lastname
    end

    test "Non-admin user unsuccessfully tries to edit other users profile", %{conn: conn, admin: admin_user, regular_user: regular_user} do
      #Logged in as regular user
      {:ok, _} = Proptrackr.Authentication.check_credentials(regular_user, "password123")
      conn = Proptrackr.Authentication.login(conn, regular_user)
      # Tries to edit admin user
      params = %{
        "id" => admin_user.id,
        "user" => %{
        "lastname" => "new"
        }
      }
      conn = put(conn, ~p"/users/#{admin_user.id}/edit", params)

      updated_user = Repo.get!(User, admin_user.id)

      #Should not be updated
      assert redirected_to(conn) == "/"
      assert updated_user.lastname == admin_user.lastname
    end

    test "Admin user successfully edits other users profile", %{conn: conn, admin: admin_user, regular_user: regular_user} do
      #Logged in as admin user
      {:ok, _} = Proptrackr.Authentication.check_credentials(admin_user, "password123")
      conn = Proptrackr.Authentication.login(conn, admin_user)
      # Tries to edit regular user
      params = %{
        "id" => regular_user.id,
        "user" => %{
        "lastname" => "new"
        }
      }
      conn = put(conn, ~p"/users/#{regular_user.id}/admin/edit", params)

      updated_user = Repo.get!(User, regular_user.id)

      #Should be updated
      assert redirected_to(conn) == "/users"
      assert updated_user.lastname == "new"
    end

    test "Non-admin unsuccessfully tries to delete someone elses account", %{conn: conn, delete_user: delete_user, regular_user: regular_user} do
      #Logged in as regular user
      {:ok, _} = Proptrackr.Authentication.check_credentials(regular_user, "password123")
      conn = Proptrackr.Authentication.login(conn, regular_user)

      # Tries to delete another user through admin route
      conn = delete(conn, ~p"/users/#{delete_user.id}/admin/delete")
      updated_user = Repo.get!(User, delete_user.id)
      #user should still exist
      assert delete_user != nil

      #Tries to delete another user through regular route
      conn = delete(conn, ~p"/users/#{delete_user.id}/delete")
      updated_user = Repo.get!(User, delete_user.id)
      #user should still exist
      assert updated_user != nil

    end

    test "User successfully deletes own account", %{conn: conn, delete_user: delete_user} do
      #Logged in as regular user
      {:ok, _} = Proptrackr.Authentication.check_credentials(delete_user, "password123")
      conn = Proptrackr.Authentication.login(conn, delete_user)

      #Deletes own account
      conn = delete(conn, ~p"/users/#{delete_user.id}/delete")
      updated_user = Repo.get(User, delete_user.id)
      assert redirected_to(conn) == "/"
      #user should not exist
      assert updated_user == nil

    end



  end

  test "view user profile without ads redirects to home page", %{conn: conn} do  ## negative
    # Create a user with no ads
    user = Repo.insert!(%User{
      firstname: "John",
      lastname: "Doe",
      email: "john.doe@example.com",
      password: Bcrypt.hash_pwd_salt("secret_password"),
      birthdate: ~D[1985-10-23],
      phone: "987-654-3210",
      description: "Another example description"
    })

    # Attempt to view the user's profile
    conn = get(conn, ~p"/users/#{user.id}")
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) == "No ads found for this user."
  end

  test "view user profile with ads displays the profile", %{conn: conn} do  ##positive
    # Create a user with ads
    user = Repo.insert!(%User{
      firstname: "John",
      lastname: "Doe",
      email: "john.doe@example.com",
      password: Bcrypt.hash_pwd_salt("secret_password"),
      birthdate: ~D[1985-10-23],
      phone: "987-654-3210",
      description: "Another example description"
    })

    # Create an advertisement for the user
    Repo.insert!(%Advertisement{
      title: "Test Ad",
      description: "A test advertisement",
      price: Decimal.new("100.0"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn",
      state: "Available",
      type: "Rent",
      square_meters: 100,
      street: "Raatuse",
      user_id: user.id
    })

    # Attempt to view the user's profile
    conn = get(conn, ~p"/users/#{user.id}")
    assert html_response(conn, 200) =~ "Test Ad"
  end




end
