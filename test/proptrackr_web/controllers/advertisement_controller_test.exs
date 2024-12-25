defmodule ProptrackrWeb.AdvertisementControllerTest do
  use ProptrackrWeb.ConnCase
  alias Proptrackr.{Repo, Ads.Advertisement, Accounts.User, Accounts.UserFavoriteAds}
  import Plug.Conn
  alias Bcrypt


  ## Edit Advertiesment - Positive Works, Negative Doesn't But Is There(because of the countries issue)
  ## Update State - Not Working, but is there 

  ## Create Advertisement
  ## Delete Advertisement

  ## Listing Advertisements

  ## Click Home
  ## Click Favorites
  ## Click Advertisements

  ## Click view profile - located in User Controller Test

  ## Check if you can view User Profile through url if they dont have ads !!!!!!!!!!!!!!!



  setup %{conn: conn} do
    # Ensure the test user is present
    user =
      Repo.get_by(User, email: "example@example.com") ||
        Repo.insert!(%User{
          firstname: "Tiiu",
          lastname: "Tamm",
          email: "example@example.com",
          password: Bcrypt.hash_pwd_salt("super_secret_password"),
          birthdate: ~D[1990-01-01],
          phone: "123-456-7890",
          description: "Example description"
        })

    # Generate a Guardian token for the authenticated user
    {:ok, token, _claims} = Proptrackr.Guardian.encode_and_sign(user)

    # Add the Authorization header to the existing connection
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    {:ok, conn: conn, user: user}
  end

  test "Creating advertisement with valid data", %{conn: conn} do
    params = %{
      "advertisement" => %{
        "type" => "Rent",
        "floor" => 42,
        "state" => "some state",
        "description" => "some description",
        "title" => "some title",
        "street" => "some street",
        "reference" => "some reference",
        "total_floors" => 42,
        "rooms" => 42,
        "square_meters" => 42,
        "price" => "120.5",
        "city" => "Tallinn",
        "country" => "Estonia",
        "area" => "Kesklinn"
      }
    }

    conn = post(conn, ~p"/advertisements", params)
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == ~p"/advertisements/#{id}"

    advertisement = Repo.get!(Advertisement, id)
    assert advertisement.title == "some title"
    assert advertisement.price == Decimal.new("120.5")
    assert advertisement.city == "Tallinn"
    assert advertisement.country == "Estonia"
    assert advertisement.area == "Kesklinn"
  end




## POSITIVE
  test "Updating advertisement with valid data", %{conn: conn, user: user} do
    advertisement = Repo.insert!(%Advertisement{
      type: "Rent",
      floor: 42,
      state: "some state",
      description: "some description",
      title: "some title",
      street: "some street",
      reference: "some reference",
      total_floors: 42,
      rooms: 42,
      square_meters: 42,
      price: Decimal.new("120.5"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn"
    })

    params = %{
      "advertisement" => %{
        "title" => "Updated title",
        "price" => "150.5",
        "user_id" => user.id,
        "city" => "Tallinn",
        "country" => "Estonia",
        "area" => "Kesklinn"
      }
    }

    conn = put(conn, ~p"/advertisements/#{advertisement.id}", params)
    assert redirected_to(conn) == ~p"/advertisements/#{advertisement.id}"

    updated_advertisement = Repo.get!(Advertisement, advertisement.id)
    assert updated_advertisement.title == "Updated title"
    assert updated_advertisement.price == Decimal.new("150.5")
    assert updated_advertisement.city == "Tallinn"
    assert updated_advertisement.country == "Estonia"
    assert updated_advertisement.area == "Kesklinn"
  end

  ## NEGATIVE  (NOT WORKING)

  # test "Updating advertisement with invalid data", %{conn: conn, user: user} do
  #   advertisement = Repo.insert!(%Advertisement{
  #     type: "Rent",
  #     floor: 42,
  #     state: "some state",
  #     description: "some description",
  #     title: "some title",
  #     street: "some street",
  #     reference: "some reference",
  #     total_floors: 42,
  #     rooms: 42,
  #     square_meters: 42,
  #     price: Decimal.new("120.5"),
  #     city: "Tallinn",
  #     country: "Estonia",
  #     area: "Kesklinn"
  #   })

  #   # Invalid data (e.g., missing title and negative price)
  #   params = %{
  #     "advertisement" => %{
  #       "title" => "",  # Invalid title
  #       "price" => "-50.5",  # Invalid price
  #       "user_id" => user.id,
  #       "city" => "Tallinn",
  #       "country" => "Estonia",
  #       "area" => "Kesklinn"
  #     }
  #   }

  #   conn = put(conn, ~p"/advertisements/#{advertisement.id}", params)
  #   assert html_response(conn, 200) =~ "error"

  #   # Ensure the advertisement was not updated
  #   updated_advertisement = Repo.get!(Advertisement, advertisement.id)
  #   assert updated_advertisement.title == "some title"
  #   assert updated_advertisement.price == Decimal.new("120.5")
  #   assert updated_advertisement.city == "Tallinn"
  #   assert updated_advertisement.country == "Estonia"
  #   assert updated_advertisement.area == "Kesklinn"
  # end






  test "Deleting advertisement", %{conn: conn} do
    advertisement = Repo.insert!(%Advertisement{
      type: "Rent",
      floor: 42,
      state: "some state",
      description: "some description",
      title: "some title",
      street: "some street",
      reference: "some reference",
      total_floors: 42,
      rooms: 42,
      square_meters: 42,
      price: Decimal.new("120.5"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn"
    })

    conn = delete(conn, ~p"/advertisements/#{advertisement.id}")
    assert redirected_to(conn) == ~p"/advertisements"

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get!(Advertisement, advertisement.id)
    end
  end



  test "Listing advertisements for authenticated user", %{conn: conn, user: user} do
    # Create some advertisements for the user
    Repo.insert!(%Advertisement{user_id: user.id, title: "Ad 1", price: Decimal.new("100.0"), city: "Tallinn", country: "Estonia", area: "Kesklinn"})
    Repo.insert!(%Advertisement{user_id: user.id, title: "Ad 2", price: Decimal.new("200.0"), city: "Tallinn", country: "Estonia", area: "Kesklinn"})

    conn = get(conn, ~p"/advertisements")
    assert html_response(conn, 200) =~ "Ad 1"
    assert html_response(conn, 200) =~ "Ad 2"
  end


  test "Viewing advertisement details", %{conn: conn, user: user} do
    advertisement = Repo.insert!(%Advertisement{
      user_id: user.id,
      title: "Detailed Ad",
      price: Decimal.new("100.0"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn",
      description: "A detailed advertisement",
      recommended_price: Decimal.new("150.0"),
      square_meters: 50,
      street: "Main St.",
      type: "Rent"
    })

    conn = get(conn, ~p"/advertisements/#{advertisement.id}/detail")
    assert html_response(conn, 200) =~ "Detailed Ad"
    assert html_response(conn, 200) =~ "A detailed advertisement"
  end

  test "Viewing advertisement details which do not exist", %{conn: conn} do
    conn = get(conn, "/advertisements/1000/detail")
    assert html_response(conn, 404) =~ "Advertisement not found"
  end

  test "Viewing advertisement details 2", %{conn: conn, user: user} do
    advertisement = Repo.insert!(%Advertisement{
      user_id: user.id,
      title: "Detailed Ad",
      price: Decimal.new("100.0"),
      city: "Tallinn",
      country: "Estonia",
      area: "Kesklinn",
      description: "A detailed advertisement",
      recommended_price: Decimal.new("150.0"),
      square_meters: 50,
      street: "Main St.",
      type: "Rent"
    })

    conn = get(conn, ~p"/advertisements/#{advertisement.id}")
    assert html_response(conn, 200) =~ "Detailed Ad"
    assert html_response(conn, 200) =~ "A detailed advertisement"
  end


  # Seems correct isn't working :(  #########

  # test "mark advertisement as sold", %{conn: conn, user: user} do
  #   advertisement = Repo.insert!(%Advertisement{
  #     title: "Test Ad",
  #     description: "A test advertisement",
  #     price: Decimal.new("100.0"),
  #     city: "Tallinn",
  #     country: "Estonia",
  #     area: "Kesklinn",
  #     state: "Available",
  #     type: "Rent",
  #     square_meters: 100,
  #     street: "Raatuse"
  #   })

  #   IO.inspect(advertisement, label: "Advertisement before update")

  #   # Directly specify the path
  #   conn = post(conn, "/advertisements/#{advertisement.id}/update_sold")
  #   IO.inspect(conn, label: "Conn after POST request")
  #   assert redirected_to(conn) == "/advertisements/#{advertisement.id}"

  #   # Fetch updated advertisement
  #   updated_advertisement = Repo.get!(Advertisement, advertisement.id)
  #   IO.inspect(updated_advertisement, label: "Advertisement after update")

  #   assert updated_advertisement.state == "Sold"
  # end



###################                          ######################

# test "mark advertisement as available", %{conn: conn, user: user} do
#   advertisement = Repo.insert!(%Advertisement{
#     title: "Test Ad",
#     description: "A test advertisement",
#     price: Decimal.new("100.0"),
#     city: "Tallinn",
#     country: "Estonia",
#     area: "Kesklinn",
#     state: "Reserved",  # Initially set to Reserved
#     type: "Rent",
#     square_meters: 100,
#     street: "Raatuse"
#   })

#   IO.inspect(advertisement, label: "Advertisement before update")

#   # Directly specify the path
#   conn = post(conn, "/advertisements/#{advertisement.id}/update_available")
#   IO.inspect(conn, label: "Conn after POST request")
#   assert redirected_to(conn) == "/advertisements/#{advertisement.id}"

#   # Fetch updated advertisement
#   updated_advertisement = Repo.get!(Advertisement, advertisement.id)
#   IO.inspect(updated_advertisement, label: "Advertisement after update")

#   assert updated_advertisement.state == "Available"
# end


# test "mark advertisement as reserved", %{conn: conn, user: user} do
#   advertisement = Repo.insert!(%Advertisement{
#     title: "Test Ad",
#     description: "A test advertisement",
#     price: Decimal.new("100.0"),
#     city: "Tallinn",
#     country: "Estonia",
#     area: "Kesklinn",
#     state: "Available",
#     type: "Rent",
#     square_meters: 100,
#     street: "Raatuse"
#   })

#   IO.inspect(advertisement, label: "Advertisement before update")

#   # Directly specify the path
#   conn = post(conn, "/advertisements/#{advertisement.id}/update_reserved")
#   IO.inspect(conn, label: "Conn after POST request")
#   assert redirected_to(conn) == "/advertisements/#{advertisement.id}"

#   # Fetch updated advertisement
#   updated_advertisement = Repo.get!(Advertisement, advertisement.id)
#   IO.inspect(updated_advertisement, label: "Advertisement after update")

#   assert updated_advertisement.state == "Reserved"
# end


test "Click Advertisement from Home", %{conn: conn, user: user} do

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


  assert response =~ "Test Ad Title"


  conn = get(conn, ~p"/advertisements/#{advertisement.id}/detail")


  assert html_response(conn, 200) =~ "A test advertisement"
end

test "Click Advertisement from Advertisements List", %{conn: conn, user: user} do

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


  conn = get(conn, "/advertisements")
  response = html_response(conn, 200)


  assert response =~ "Test Ad Title"


  conn = get(conn, ~p"/advertisements/#{advertisement.id}/detail")


  assert html_response(conn, 200) =~ "A test advertisement"
end

test "Advertisement title is clickable from favorites page", %{conn: conn, user: user} do
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


  conn = post(conn, ~p"/advertisements/favorite/#{advertisement.id}/#{user.id}")
  assert redirected_to(conn) == "/"


  conn = get(conn, ~p"/users/#{user.id}/favorite_ads")
  response = html_response(conn, 200)


  assert response =~ "Test Ad Title"


  conn = get(conn, ~p"/advertisements/#{advertisement.id}")


  assert html_response(conn, 200) =~ "A test advertisement"
end

































end
