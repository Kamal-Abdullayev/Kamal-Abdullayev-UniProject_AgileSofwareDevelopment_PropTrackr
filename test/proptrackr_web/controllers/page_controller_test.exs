defmodule ProptrackrWeb.PageControllerTest do
  use ProptrackrWeb.ConnCase

  alias Proptrackr.{Repo, Ads.Advertisement, Accounts.UserNotInterested, Accounts.User}

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Submit"
  end

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

  test "renders the home page with advertisements", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200)

    assert html_response(conn, 200) =~ "<form action=\"/search\">"
    assert html_response(conn, 200) =~ "placeholder=\"Search...\""
    assert html_response(conn, 200) =~ "class=\"row\""

  end

  test "renders the home page with advertisements contact button without phone number", %{conn: conn} do
    # Create a new advertisement struct (assuming the advertisement schema is called `Advertisement`)
    advertisement = %{
      "advertisement" => %{
        "type" => "Rent",
        "floor" => 42,
        "state" => "some state",
        "description" => "some description",
        "title" => "title1",
        "street" => "some street",
        "reference" => "some reference",
        "total_floors" => 42,
        "rooms" => 42,
        "square_meters" => 42,
        "price" => "120.5",
        "area" => "Kesklinn",
        "city" => "Tallinn",
        "country" => "Estonia",
      }
    }

    conn = get(conn, ~p"/", advertisement)

    html = html_response(conn, 200)
    assert String.contains?(html, "Contact Number: ")

  end



  test "search advertisement ordering", %{conn: conn} do
    advertisement = %{
      "advertisement" => %{
        "type" => "Rent",
        "floor" => 42,
        "state" => "some state",
        "description" => "some description",
        "title" => "title1",
        "street" => "some street",
        "reference" => "some reference",
        "total_floors" => 42,
        "rooms" => 42,
        "square_meters" => 42,
        "price" => "120.5",
        "area" => "Kesklinn",
        "city" => "Tallinn",
        "country" => "Estonia"
      }
    }

    second_advertisement = %{
      "advertisement" => %{
        "type" => "Rent",
        "floor" => 42,
        "state" => "some state",
        "description" => "some description 2",
        "title" => "title second",
        "street" => "some street",
        "reference" => "some reference",
        "total_floors" => 42,
        "rooms" => 42,
        "square_meters" => 42,
        "price" => "120.5",
        "area" => "Kesklinn",
        "city" => "Tallinn",
        "country" => "Estonia"
      }
    }

    conn = post(conn, ~p"/advertisements", advertisement)
    conn = post(conn, ~p"/advertisements", second_advertisement)
    conn = get(conn, ~p"/advertisements/not_interested/1/1")
    conn = get(conn, ~p"/search?search=description&type=Rent&country=Estonia&min_price=&max_price=&min_rooms=&max_rooms=")

    assert html_response(conn, 200) =~ "description"
  end

  test "access past search history", %{conn: conn} do
    conn = get(conn, ~p"/search?search=AAAAAAAA&type=Rent&country=Estonia")
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "AAAAAAAA"
  end

end
