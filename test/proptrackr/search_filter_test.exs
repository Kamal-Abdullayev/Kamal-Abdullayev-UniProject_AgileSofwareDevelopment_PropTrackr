defmodule ProptrackrWeb.SearchFilterTest do
  use ProptrackrWeb.ConnCase
  alias Proptrackr.{Repo,Ads,Search.Filter}

  @valid_attrs %{
    search: "",
    country: "Estonia",
    min_price: 0,
    max_price: 1000000,
    min_rooms: 1,
    max_rooms: 2,
  }

  # Test valid data
  test "valid attributes filter" do
    changeset = Filter.changeset(%Filter{}, @valid_attrs)
    assert changeset.valid?
  end

  @invalid_attrs %{
    search: "",
    country: "Estonia",
    min_price: 0,
    max_price: 1000000,
    min_rooms: 0,
    max_rooms: 2,
  }

  # 0 rooms : invalid
  test "invalid filter" do
    changeset = Filter.changeset(%Filter{}, @invalid_attrs)
    refute changeset.valid?
  end

  @neg_price_attrs %{
    search: "",
    country: "Estonia",
    min_price: -1,
    max_price: 1000000,
    min_rooms: 1,
    max_rooms: 2,
  }

  # negative price: invalid
  test "negative price filter" do
    changeset = Filter.changeset(%Filter{}, @neg_price_attrs)
    refute changeset.valid?
  end

  @max_smaller_attrs %{
    search: "",
    country: "Estonia",
    min_price: 1000000,
    max_price: 2,
    min_rooms: 1,
    max_rooms: 2,
  }

  # max < min price
  test "max smaller filter" do
    changeset = Filter.changeset(%Filter{}, @max_smaller_attrs)
    refute changeset.valid?
  end

  @max_larger_attrs %{
    search: "",
    country: "Estonia",
    min_price: 10,
    max_price: 100000,
    min_rooms: 1,
    max_rooms: 2,
  }

  # max > min price : valid
  test "max larger filter" do
    changeset = Filter.changeset(%Filter{}, @max_larger_attrs)
    assert changeset.valid?
  end

end
