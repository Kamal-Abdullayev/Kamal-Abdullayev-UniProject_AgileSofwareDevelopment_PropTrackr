defmodule Proptrackr.Ads.AdvertisementTest do
  use ExUnit.Case
  alias Proptrackr.Ads.Advertisement

  ## Testing:
  ## 1) All inputs corect
  ## 2) Missing all fields
  ## 3) Checking if it catches wrong phone numbers
  ## 4) Required attributes only allow to create an ad with optional fields missing
  ## 5) Valid price check ** add more
  ## 6) Invalid price check
  ## 7) Invalid Squrare Meters
  ## 8) Invalid room numbers
  ## 9) Invalid floor, total floors
  ## 10) Floor does not exceel total floor





  ## POSITIVE SCENARIO ###########

  describe "changeset/2" do
    test "valid attributes create a valid changeset" do
      valid_attrs = %{
        title: "Beautiful apartment",
        description: "A cozy place to live.",
        price: Decimal.new(200000),
        photo_path: "/photos/apartment.jpg",
        type: "Sale",
        square_meters: 50,
        street: "Main St.",
        rooms: 2,
        floor: 3,
        total_floors: 5,
        reference: "12345",
        state: "Available",
        user_id: 1,
        phone_number: "+372 1234 5678",
        country: "Estonia",
        city: "Tartu",
        area: "karlova"
      }

      changeset = Advertisement.changeset(%Advertisement{}, valid_attrs)
      assert changeset.valid?
    end

    ## NEGATIVE SCENARIO #########
    test "missing required attributes results in an invalid changeset" do
      invalid_attrs = %{}

      changeset = Advertisement.changeset(%Advertisement{}, invalid_attrs)
      refute changeset.valid?
      assert length(changeset.errors) > 0
    end


    ## NEGATIVE SCENARIO ##########
    test "multiple incorrect phone number formats result in an invalid changeset" do
      invalid_phone_numbers = [
        "12345678",           # Too short, no country code
        "+372 123 456",       # Too short
        "+372-1234-5678x123", # Extension not allowed
        "00437212345678",     # Incorrect country code format
        "+372.123.456.78"     # Incorrect delimiter
      ]

      Enum.each(invalid_phone_numbers, fn phone_number ->
        attrs = %{
          title: "Apartment with invalid phone number",
          price: Decimal.new(100000),
          square_meters: 40,
          street: "Main St.",
          type: "Sale",
          user_id: 1,
          country: "Estonia",
          city: "Tartu",
          area: "karlova",
          phone_number: phone_number
        }

        changeset = Advertisement.changeset(%Advertisement{}, attrs)
        refute changeset.valid?, "Phone number #{phone_number} should be invalid"
        assert {:phone_number, _} = Enum.find(changeset.errors, fn {field, _} -> field == :phone_number end)
      end)
    end



    ## POSITIVE SCENARIO

    test "required attributes only create a valid changeset" do
      required_attrs = %{
        title: "Apartment",
        price: Decimal.new(100000),
        square_meters: 40,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova"
      }

      changeset = Advertisement.changeset(%Advertisement{}, required_attrs)
      assert changeset.valid?
    end

    ## POSITIVE SCENARIO ######
    test "valid price creates a valid changeset" do
      valid_price_attrs = %{
        title: "Apartment with valid price",
        price: Decimal.new(200000),
        square_meters: 60,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova"
      }

      changeset = Advertisement.changeset(%Advertisement{}, valid_price_attrs)
      assert changeset.valid?
    end

    ## NEGATIVE SCENARIO ###########
    test "invalid price creates an invalid changeset" do
      invalid_price_attrs = %{
        title: "Apartment with invalid price",
        price: "invalid_price",
        square_meters: 60,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova"
      }

      changeset = Advertisement.changeset(%Advertisement{}, invalid_price_attrs)
      refute changeset.valid?
      assert {:price, _} = Enum.find(changeset.errors, fn {field, _} -> field == :price end)
    end


  ## NEGATIVE SCENARIO #######
    test "invalid square_meters results in an invalid changeset" do
      invalid_square_meters_attrs = %{
        title: "Apartment with invalid square_meters",
        price: Decimal.new(200000),
        square_meters: -10, # Negative value
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova"
      }

      changeset = Advertisement.changeset(%Advertisement{}, invalid_square_meters_attrs)
      refute changeset.valid?
      assert {:square_meters, _} = Enum.find(changeset.errors, fn {field, _} -> field == :square_meters end)
    end

    ## NEGATIVE SCENARIO #######
    test "invalid rooms results in an invalid changeset" do
      invalid_rooms_attrs = %{
        title: "Apartment with invalid rooms",
        price: Decimal.new(200000),
        square_meters: 50,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova",
        rooms: -1 # Negative value
      }

      changeset = Advertisement.changeset(%Advertisement{}, invalid_rooms_attrs)
      refute changeset.valid?
      assert {:rooms, _} = Enum.find(changeset.errors, fn {field, _} -> field == :rooms end)
    end

    ## NEGATIVE SCENARIO #######

    test "invalid floor or total_floors results in an invalid changeset" do
      invalid_floor_attrs = %{
        title: "Apartment with invalid floor",
        price: Decimal.new(200000),
        square_meters: 50,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova",
        floor: -1 # Negative value
      }

      changeset = Advertisement.changeset(%Advertisement{}, invalid_floor_attrs)
      refute changeset.valid?
      assert {:floor, _} = Enum.find(changeset.errors, fn {field, _} -> field == :floor end)

      ## NEGATIVE SCENARIO ########
      invalid_total_floors_attrs = %{
        title: "Apartment with invalid total_floors",
        price: Decimal.new(200000),
        square_meters: 50,
        street: "Main St.",
        type: "Sale",
        user_id: 1,
        country: "Estonia",
        city: "Tartu",
        area: "karlova",
        total_floors: -1 # Negative value
      }

      changeset = Advertisement.changeset(%Advertisement{}, invalid_total_floors_attrs)
      refute changeset.valid?
      assert {:total_floors, _} = Enum.find(changeset.errors, fn {field, _} -> field == :total_floors end)
    end
  end

  ## NEGATIVE SCENARIO ############
  test "floor number does not exceed total floors" do
    attrs = %{
      title: "Apartment",
      price: Decimal.new(100000),
      square_meters: 40,
      street: "Main St.",
      type: "Sale",
      user_id: 1,
      country: "Estonia",
      city: "Tartu",
      area: "karlova",
      floor: 6,
      total_floors: 5
    }

    changeset = Advertisement.changeset(%Advertisement{}, attrs)
    refute changeset.valid?
    assert {:floor, _} = Enum.find(changeset.errors, fn {field, _} -> field == :floor end)
  end

  describe "calculate_recommended_price/1" do
    test "correctly calculates the sale price" do
      ad = %Advertisement{square_meters: 50, rooms: 2, area: "karlova", type: "Sale"}
      assert Advertisement.calculate_recommended_price(ad) == 150_000
    end

    test "correctly calculates the rent price" do
      ad = %Advertisement{square_meters: 50, rooms: 2, area: "karlova", type: "Rent"}
      assert Advertisement.calculate_recommended_price(ad) == 750.0
    end

    test "raises error for invalid type" do
      ad = %Advertisement{square_meters: 50, rooms: 2, area: "karlova", type: "Lease"}

      assert_raise ArgumentError, fn -> Advertisement.calculate_recommended_price(ad) end
    end
  end

end
