defmodule ProptrackrWeb.AdvertisementController do
  use ProptrackrWeb, :controller

  alias Proptrackr.Ads
  alias Proptrackr.Ads.Advertisement
  alias Proptrackr.Authentication
  alias Proptrackr.Accounts.UserFavoriteAds
  alias Proptrackr.Accounts.UserNotInterested
  alias Proptrackr.Repo
  alias Proptrackr.Locations.Location

  def favorite(conn, %{"advertisement_id" => advertisement_id, "user_id" => user_id}) do
    current_user = Proptrackr.Authentication.load_current_user(conn)

    if current_user && current_user.id == String.to_integer(user_id) do
      advertisement = Repo.get(Advertisement, advertisement_id)

      if advertisement do
        # Check if the advertisement is already in the favorites list
        existing_favorite = Repo.get_by(UserFavoriteAds, user_id: current_user.id, advertisement_id: advertisement.id)

        if existing_favorite do
          # If it exists, remove it from the favorites
          Repo.delete(existing_favorite)

          conn
          |> put_flash(:info, "Advertisement removed from your favorites.")
          |> redirect(to: ~p"/")

        else
          # If it doesn't exist, add it to the favorites
          changeset = UserFavoriteAds.changeset(%UserFavoriteAds{}, %{
            user_id: current_user.id,
            advertisement_id: advertisement.id
          })

          case Repo.insert(changeset) do
            {:ok, _favorite} ->
              conn
              |> put_flash(:info, "Advertisement added to your favorites.")
              |> redirect(to: ~p"/")

            {:error, _changeset} ->
              conn
              |> put_flash(:error, "Something went wrong while adding the advertisement to your favorites.")
              |> redirect(to: ~p"/")
          end
        end
      else
        conn
        |> put_flash(:error, "Advertisement not found.")
        |> redirect(to: ~p"/")
      end
    else
      conn
      |> put_flash(:error, "You must be logged in to favorite an advertisement.")
      |> redirect(to: ~p"/")
    end
  end


  def remove_favorite(conn, %{"id" => id}) do
    user = Proptrackr.Authentication.load_current_user(conn)

    favorite =
      Repo.get_by(Proptrackr.Accounts.UserFavoriteAds, user_id: user.id, advertisement_id: id)

    if favorite do
      Repo.delete(favorite)
      conn
      |> put_flash(:info, "Advertisement removed from your 'Favorites' list.")
      |> redirect(to: ~p"/users/#{user.id}/favorite_ads")
    else
      conn
      |> put_flash(:error, "Something went wrong.")
      |> redirect(to: ~p"/users/#{user.id}/favorite_ads")
    end
  end

 def favorite_ads(conn, _params) do
  user = Proptrackr.Authentication.load_current_user(conn)
  user = Repo.preload(user, :favorite_ads)

  favorite_ads = user.favorite_ads

  render(conn, "favorite_ads.html", favorite_ads: favorite_ads)
end


  def remove_not_interested(conn, %{"id" => id}) do
    user = Proptrackr.Authentication.load_current_user(conn)

    user_not_interested_ad =
      Repo.get_by(Proptrackr.Accounts.UserNotInterested, user_id: user.id, advertisement_id: id)

    if user_not_interested_ad do
      Repo.delete(user_not_interested_ad)
      conn
      |> put_flash(:info, "Advertisement removed from your 'Not Interested' list.")
      |> redirect(to: ~p"/users/#{user.id}/not_interested_ads")
    else
      conn
      |> put_flash(:error, "Advertisement not found in your 'Not Interested' list.")
      |> redirect(to: ~p"/users/#{user.id}/not_interested_ads")
    end
  end


  def not_interested_ads(conn, _params) do
    user = Proptrackr.Authentication.load_current_user(conn)
    user = Repo.preload(user, :not_interesting_ads)

    not_interested_ads = user.not_interesting_ads

    render(conn, "not_interested_ads.html", not_interested_ads: not_interested_ads)
  end

  def not_interested(conn, %{"advertisement_id" => advertisement_id, "user_id" => user_id}) do
    current_user = Proptrackr.Authentication.load_current_user(conn)

    if current_user && current_user.id == String.to_integer(user_id) do
      advertisement = Repo.get(Advertisement, advertisement_id)

      if advertisement do
        changeset = UserNotInterested.changeset(%UserNotInterested{}, %{
          user_id: current_user.id,
          advertisement_id: advertisement.id
        })

        case Repo.insert(changeset) do
          {:ok, _user_not_interested} ->
            conn
            |> put_flash(:info, "You have marked this advertisement as not interested.")
            |> redirect(to: ~p"/")

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "You have already marked this advertisement as 'Not Interested'")
            |> redirect(to: ~p"/")
        end
      else
        conn
        |> put_flash(:error, "Advertisement not found.")
        |> redirect(to: ~p"/")
      end
    else
      conn
      |> put_flash(:error, "You must be logged in to perform this action.")
      |> redirect(to: ~p"/")
    end
  end

  def index(conn, _params) do
    current_user = Authentication.load_current_user(conn)

    if current_user do
      advertisements = Ads.list_advertisements_for_user(current_user.id)

      render(conn, "index.html", advertisements: advertisements)
    else
      conn
      |> put_flash(:error, "You must be logged in to view your advertisements.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def new(conn, _params) do
    # Fetch unique countries, cities, and areas
    countries = Repo.all(Location) |> Enum.map(& &1.country) |> Enum.uniq()
    cities = Repo.all(Location) |> Enum.map(& &1.city) |> Enum.uniq()
    areas = Repo.all(Location) |> Enum.map(& &1.area) |> Enum.uniq()
    existing_images = []  # Ensure this key is present
    IO.inspect(countries, label: "Countries")
    IO.inspect(cities, label: "Cities")
    IO.inspect(areas, label: "Areas")

    # Prepare an empty changeset for the advertisement form
    changeset = Ads.change_advertisement(%Ads.Advertisement{})

    # Render the advertisement form
    render(conn, "new.html", changeset: changeset, countries: countries, cities: cities, areas: areas, existing_images: existing_images)
  end






  # Assuming you have a Location model
def create(conn, %{"advertisement" => advertisement_params}) do
  countries = Repo.all(Location) |> Enum.map(& &1.country) |> Enum.uniq()
  cities = Repo.all(Location) |> Enum.map(& &1.city) |> Enum.uniq()
  areas = Repo.all(Location) |> Enum.map(& &1.area) |> Enum.uniq()
  changeset = Ads.change_advertisement(%Advertisement{}, advertisement_params)
  existing_images = []
  current_user = Proptrackr.Authentication.load_current_user(conn)
  if current_user do
    if !current_user.is_blocked do
      # Automatically set the user_id to the logged-in user
      advertisement_params = Map.put(advertisement_params, "user_id", current_user.id)

      # Handle the uploaded files (images)
      uploaded_images = Map.get(advertisement_params, "photo", [])

      # If images are uploaded, save them to the uploads directory
      photo_paths =
        Enum.map(uploaded_images, fn uploaded_image ->
          save_image(uploaded_image)
        end)

      # Add the photo_paths to the advertisement params (store as an array)
      advertisement_params = Map.put(advertisement_params, "photo_paths", photo_paths)

      # Handle location (create or fetch a Location record)
      location_params = %{
        country: Map.get(advertisement_params, "country"),
        city: Map.get(advertisement_params, "city"),
        area: Map.get(advertisement_params, "area")
      }

      # Create the location if not already existing
      location = Repo.get_by(Location, location_params) || Repo.insert!(Location.changeset(%Location{}, location_params))


      # Add the location_id to the advertisement params
      advertisement_params = Map.put(advertisement_params, "location_id", location.id)


      # Create the advertisement
      case Ads.create_advertisement(advertisement_params) do
        {:ok, advertisement} ->
          Enum.each(photo_paths, fn path ->
            %Proptrackr.Ads.AdvertisementImage{}
            |> Proptrackr.Ads.AdvertisementImage.changeset(%{
              advertisement_id: advertisement.id,
              image_path: path
            })
            |> Repo.insert()
          end)

          conn
          |> put_flash(:info, "Advertisement created successfully.")
          |> redirect(to: ~p"/advertisements/#{advertisement.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, countries: countries, cities: cities, areas: areas, existing_images: existing_images)
    end
  else
    # If no user is logged in, redirect to login page
    conn
    |> put_flash(:error, "You must be logged in to create an advertisement.")
    |> redirect(to: ~p"/")
    |> halt()
  end
end
end


  defp save_image(%Plug.Upload{path: temp_path, filename: filename}) do
    # Ensure the filename is unique (e.g., by appending a timestamp or random string)
    unique_filename = "#{UUID.uuid4()}_#{filename}"

    # Define the destination path
    destination = Path.join("priv/static/uploads", unique_filename)

    IO.inspect("Saving image: #{filename} to #{destination}", label: "Save Image")

    # Copy the uploaded file to the uploads folder
    case File.cp(temp_path, destination) do
      :ok ->
        IO.inspect("Image saved successfully!", label: "Success")
        "/uploads/#{unique_filename}"

      {:error, reason} ->
        IO.inspect("Failed to save image: #{reason}", label: "Error")
        nil
    end
  end






  def show(conn, %{"id" => id}) do
    try do

      advertisement = Ads.get_advertisement!(id)
      advertisement_with_recommended_price = %{
        advertisement
        | recommended_price: Proptrackr.Ads.Advertisement.calculate_recommended_price(advertisement)
      }

      recommended_properties = Ads.get_recommended_properties(advertisement)

    render(conn, :show,
      advertisement: advertisement_with_recommended_price,
      recommended_properties: recommended_properties
    )
      render(conn, :show,
        advertisement: advertisement_with_recommended_price,
        recommended_properties: recommended_properties
      )
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(404, "Advertisement not found")
    end
  end


  def show_detail(conn, %{"id" => id}) do
      try do
        advertisement = Ads.get_advertisement!(id)

        advertisement_with_recommended_price = %{
          advertisement
          | recommended_price: Proptrackr.Ads.Advertisement.calculate_recommended_price(advertisement)
        }

        recommended_properties = Ads.get_recommended_properties(advertisement)

        render(conn, :ads_detail,
          advertisement: advertisement_with_recommended_price,
          recommended_properties: recommended_properties
        )
      rescue
        Ecto.NoResultsError ->
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(404, "Advertisement not found")
      end
    end


  def edit(conn, %{"id" => id}) do
    advertisement = Ads.get_advertisement!(id)
    changeset = Ads.change_advertisement(advertisement)

    countries = Ads.list_countries()
    cities = Ads.get_cities_for_country(advertisement.country || "")
    areas = Ads.get_areas_for_city(advertisement.country || "", advertisement.city || "")

    # Ensure the photo paths are correctly constructed
    existing_images = Enum.map(advertisement.photo_paths, fn path ->
      "/uploads/#{Path.basename(path)}"
    end)

    render(conn, :edit,
      advertisement: advertisement,
      changeset: changeset,
      countries: countries,
      cities: cities,
      areas: areas,
      existing_images: existing_images
    )
  end






  def update(conn, %{"id" => id, "advertisement" => advertisement_params}) do
    countries = Repo.all(Location) |> Enum.map(& &1.country) |> Enum.uniq()
    cities = Repo.all(Location) |> Enum.map(& &1.city) |> Enum.uniq()
    areas = Repo.all(Location) |> Enum.map(& &1.area) |> Enum.uniq()
    changeset = Ads.change_advertisement(%Advertisement{}, advertisement_params)
    existing_images = []
    advertisement = Ads.get_advertisement!(id)

    uploaded_images = Map.get(advertisement_params, "photo", [])

    new_photo_paths = Enum.map(uploaded_images, fn uploaded_image ->
      save_image(uploaded_image)
    end)

    deleted_images = Map.get(advertisement_params, "deleted_images", [])

    # Clean paths by removing redundant `/uploads/` prefix
    cleaned_deleted_images = Enum.map(deleted_images, fn path ->
      String.replace(path, "/uploads/", "")
    end)

    # Remove deleted images from the current photo paths
    remaining_photo_paths = Enum.reject(advertisement.photo_paths, fn path ->
      cleaned_path = String.replace(path, "/uploads/", "")
      cleaned_path in cleaned_deleted_images
    end)

    # Combine the remaining and new photo paths
    photo_paths = remaining_photo_paths ++ new_photo_paths

    updated_params = Map.put(advertisement_params, "photo_paths", photo_paths)

    case Ads.update_advertisement(advertisement, updated_params) do
      {:ok, advertisement} ->
        conn
        |> put_flash(:info, "Advertisement updated successfully.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, countries: countries, cities: cities, areas: areas, existing_images: existing_images)
    end
  end









  def delete(conn, %{"id" => id}) do
    advertisement = Ads.get_advertisement!(id)
    {:ok, _advertisement} = Ads.delete_advertisement(advertisement)

    conn
    |> put_flash(:info, "Advertisement deleted successfully.")
    |> redirect(to: ~p"/advertisements")
  end

  # Update the advertisement to "Sold"
  def update_sold(conn, %{"id" => id}) do
    advertisement = Ads.get_advertisement!(id)
    changeset = Ads.change_advertisement(advertisement, %{state: "Sold"})

    case Ads.update_advertisement(advertisement, changeset.changes) do
      {:ok, _advertisement} ->
        conn
        |> put_flash(:info, "Advertisement marked as sold.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to mark the advertisement as sold.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")

    end
  end

  # Update the advertisement to "Reserved"
  def update_reserved(conn, %{"id" => id}) do
    advertisement = Ads.get_advertisement!(id)
    changeset = Ads.change_advertisement(advertisement, %{state: "Reserved"})

    case Ads.update_advertisement(advertisement, changeset.changes) do
      {:ok, _advertisement} ->
        conn
        |> put_flash(:info, "Advertisement marked as reserved.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")


      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to mark the advertisement as reserved.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")

    end
  end

  # Update the advertisement to "Available"
  def update_available(conn, %{"id" => id}) do
    advertisement = Ads.get_advertisement!(id)
    changeset = Ads.change_advertisement(advertisement, %{state: "Available"})

    case Ads.update_advertisement(advertisement, changeset.changes) do
      {:ok, _advertisement} ->
        conn
        |> put_flash(:info, "Advertisement marked as available.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")


      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to mark the advertisement as available.")
        |> redirect(to: ~p"/advertisements/#{advertisement.id}")

    end
  end

end
