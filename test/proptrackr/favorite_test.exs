defmodule ProptrackrWeb.FavoriteTest do
  use ProptrackrWeb.ConnCase
  alias Proptrackr.{Repo,Ads.Advertisement,Authentication,Accounts.User,Accounts.UserFavoriteAds}

  test "authenticated user successfully adds advertisement to favorites", %{conn: conn} do
    user = Repo.insert!(%User{
      firstname: "Test",
      lastname: "User",
      email: "test@example.com",
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })

    advertisement = Repo.insert!(%Advertisement{
      title: "Sample Advertisement",
      description: "This is a sample advertisement."
    })

    {:ok, _} = Proptrackr.Authentication.check_credentials(user, "password123")
    conn = Proptrackr.Authentication.login(conn, user)

    params = %{
      "user_id" => user.id,
      "advertisement_id" => advertisement.id
    }

    conn = post(conn, ~p"/advertisements/favorite/#{advertisement.id}/#{user.id}", params)

    # Favorite should be added to database
    favorite = Repo.get_by(UserFavoriteAds, user_id: user.id, advertisement_id: advertisement.id)
    assert favorite != nil
    assert favorite.user_id == user.id
    assert favorite.advertisement_id == advertisement.id
    assert redirected_to(conn) == ~p"/"
  end


  test "unauthenticated user adds advertisement to favorites unsuccessfully", %{conn: conn} do

    user = Repo.insert!(%User{
      firstname: "Test",
      lastname: "User",
      email: "test@example.com",
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })

    advertisement = Repo.insert!(%Advertisement{
      title: "Sample Advertisement",
      description: "This is a sample advertisement."
    })

    params = %{
      "user_id" => user.id,
      "advertisement_id" => advertisement.id
    }

    conn = post(conn, ~p"/advertisements/favorite/#{advertisement.id}/#{user.id}", params)

    # Favorite should not be added to database
    favorite = Repo.get_by(UserFavoriteAds, user_id: user.id, advertisement_id: advertisement.id)
    assert favorite == nil

  end

end
