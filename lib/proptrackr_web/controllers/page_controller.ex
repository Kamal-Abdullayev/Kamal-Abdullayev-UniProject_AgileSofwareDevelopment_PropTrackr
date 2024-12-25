defmodule ProptrackrWeb.PageController do
  use ProptrackrWeb, :controller

  alias Proptrackr.{Repo, Locations.Location, Search.Filter, Search.History, Ads,Accounts.User}

  import Ecto.Query, only: [from: 2]


  def home(conn, _params) do
    user = Proptrackr.Authentication.load_current_user(conn)

    advertisements = Ads.list_advertisements()

    if user do
      history = Repo.all(from s in History, where: s.user_id == ^user.id, order_by: [desc: s.inserted_at], limit: 5)
      is_blocked = (Repo.get(User,user.id)).is_blocked
      favorite_ads = Repo.all(from fa in Proptrackr.Accounts.UserFavoriteAds, where: fa.user_id == ^user.id, select: fa.advertisement_id)
      not_interested_ad_ids =
        Repo.all(from a in Proptrackr.Accounts.UserNotInterested,
                 where: a.user_id == ^user.id,
                 select: a.advertisement_id)

      {interested_ads, not_interested_ads} =
        Enum.partition(advertisements, fn ad -> ad.id not in not_interested_ad_ids end)

      sorted_advertisements = interested_ads ++ not_interested_ads

      render(conn, :home, advertisements: sorted_advertisements, favorite_ads: favorite_ads,history: history, blocked: is_blocked)
    else
      render(conn, :home, advertisements: advertisements, history: [])
    end
  end

  def search(conn, params) do
    #changeset = Location.changeset(%Location{}, %{})
    changeset = Filter.changeset(%Filter{}, params)

    # Fetch all locations and extract unique countries
    countries = Repo.all(Location)
                |> Enum.map(& &1.country)
                |> Enum.uniq()

    locations = Repo.all(Location)

    cities = Repo.all(Location)
              |> Enum.map(& &1.city)
              |> Enum.uniq()

    areas = Repo.all(Location)
              |> Enum.map(& &1.area)
              |> Enum.uniq()

    if changeset.valid? do
        country = Map.get(params, "country", "")
        city = Map.get(params, "city", cities)
        area = Map.get(params, "area", areas)


        min_rooms =
          case Map.get(params, "min_rooms", "") do
            "" -> 0
            rooms -> String.to_integer(rooms)
          end


        max_rooms =
          case Map.get(params, "max_rooms", "") do
            "" -> 100 # Set an upper bound that exceeds any realistic room count
            rooms -> String.to_integer(rooms)
          end
        min_price =
          case Map.get(params, "min_price", "") do
            "" -> 0
            price -> String.to_integer(price)
          end


        max_price =
          case Map.get(params, "max_price", "") do
            "" -> 1_000_000_000 # Set an upper bound that exceeds any realistic price
            price -> String.to_integer(price)
          end


        search_term = Map.get(params, "search", "")
        type = Map.get(params, "type", "")

        user = Proptrackr.Authentication.load_current_user(conn)

        if user do
          Repo.insert(%History{user_id: user.id, keyword: search_term})
        end

        query =
          if user do
            from a in Ads.Advertisement,
              left_join: ni in subquery(from u in Proptrackr.Accounts.UserNotInterested,
                where: u.user_id == ^user.id,
                select: u.advertisement_id
              ),
              on: a.id == ni.advertisement_id,
              where: a.price >= ^min_price and a.price <= ^max_price
                and a.rooms >= ^min_rooms and a.rooms <= ^max_rooms
                and (ilike(a.city, ^"%#{city}%") or ilike(a.area, ^"%#{area}%") or ilike(a.country, ^"%#{country}%"))
                and
                (
                  ^search_term == ""
                  or ilike(a.title, ^"%#{search_term}%")
                  or ilike(a.description, ^"%#{search_term}%")
                  or ilike(a.city, ^"%#{search_term}%")
                  or ilike(a.area, ^"%#{search_term}%")
                ) and a.state != "Sold",
              order_by: [asc: is_nil(ni.advertisement_id), desc: a.inserted_at],
              select: a
          else
            from a in Ads.Advertisement,
              where: a.price >= ^min_price and a.price <= ^max_price
                and a.rooms >= ^min_rooms and a.rooms <= ^max_rooms
                and (ilike(a.city, ^"%#{city}%") or ilike(a.area, ^"%#{area}%") or ilike(a.country, ^"%#{country}%"))
                and (
                  ^search_term == ""
                  or ilike(a.title, ^"%#{search_term}%")
                  or ilike(a.description, ^"%#{search_term}%")
                  or ilike(a.city, ^"%#{search_term}%")
                  or ilike(a.area, ^"%#{search_term}%")
                ) and a.state != "Sold",
              order_by: [desc: a.inserted_at],
              select: a
          end

        # Fetch the filtered advertisements
        advertisements = Repo.all(query)

        # Render the search results page with the filtered advertisements
        render(conn, "search.html",
          changeset: changeset,
          countries: countries,
          cities: cities,
          areas: areas,
          locations: locations,
          advertisements: advertisements,
          params: params
          #favorite_ads: favorite_ads
        )
    else
      IO.inspect(changeset.errors)

      render(conn, "search.html",
          changeset: changeset,
          countries: countries,
          cities: cities,
          areas: areas,
          locations: locations,
          advertisements: [],
          params: params
          #favorite_ads: favorite_ads
        )

    end

  end

 end
