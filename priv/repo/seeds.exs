# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Proptrackr.Repo.insert!(%Proptrackr.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Proptrackr.Repo
alias Proptrackr.Accounts.User
alias Proptrackr.Repo
alias Proptrackr.Locations.Location
alias Proptrackr.Ads.Advertisement


#Seed locations
locations = [
  %{country: "Estonia", city: "Tallinn", area: "Kesklinn"},
  %{country: "Estonia", city: "Tallinn", area: "Kadriorg"},
  %{country: "Estonia", city: "Tartu", area: "Kesklinn"},
  %{country: "Estonia", city: "Tartu", area: "Annelinn"},
  %{country: "Estonia", city: "Pärnu", area: "Kesklinn"},
  %{country: "Estonia", city: "Pärnu", area: "Mereäärne"},
  %{country: "Finland", city: "Helsinki", area: "Kallio"},
  %{country: "Finland", city: "Helsinki", area: "Punavuori"},
  %{country: "Finland", city: "Turku", area: "Kauppi"},
  %{country: "Finland", city: "Turku", area: "Auranranta"}
]

Enum.each(locations, fn location_data ->
  # Check if the location already exists
  case Repo.get_by(Location, location_data) do
    nil ->
      %Location{}
      |> Location.changeset(location_data)
      |> Repo.insert!()
      IO.puts("Inserted: #{inspect(location_data)}")

    _existing_location ->
      IO.puts("Skipped (already exists): #{inspect(location_data)}")
  end
end)

# List of users
users = [
  %{firstname: "Mark", lastname: "Smith", email: "mark.smith@example.com", password: "secure_password123", birthdate: ~D[1985-03-15], phone: "987-654-3210", description: "Mark's description"},
  %{firstname: "Anna", lastname: "Jensen", email: "anna.jensen@example.com", password: "password_anna", birthdate: ~D[1992-07-20], phone: "555-123-9876", description: "Anna's description"},
  %{firstname: "John", lastname: "Doe", email: "john.doe@example.com", password: "john_password", birthdate: ~D[1988-12-05], phone: "555-987-1234", description: "John's description"},
  %{firstname: "Eva", lastname: "Larsen", email: "eva.larsen@example.com", password: "eva_password", birthdate: ~D[1995-06-30], phone: "555-234-5678", description: "Eva's description"},
  %{firstname: "Admin", lastname: "Admin", email: "admin.admin@example.com", password: "123456789", birthdate: ~D[1995-06-30], phone: "512-345-6789", description: "Example description", is_admin: true}
]

Enum.each(users, fn user_data ->
  email = String.downcase(user_data.email)

  # Check if the user already exists by email
  case Repo.get_by(Proptrackr.Accounts.User, email: email) do
    nil ->
      # Insert only if the user doesn't exist
      %Proptrackr.Accounts.User{}
      |> Proptrackr.Accounts.User.changeset(%{user_data | email: email})
      |> Repo.insert!()
      IO.puts("Inserted: #{user_data.email}")

    _existing_user ->
      IO.puts("Skipped (already exists): #{user_data.email}")
  end
end)



#Seed
ads = [
    %{title: "Modern Apartment in Kesklinn", description: "A modern 2-bedroom apartment in the heart of Tallinn.", price: 1000, images: [], type: "Rent", square_meters: 60, location: "Kesklinn, Tallinn, Estonia", rooms: 2, floor: 3, total_floors: 5, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kesklinn", street: "Tähe", user_id: 1, phone_number: "372 0000 0000"},
    %{title: "Luxury Villa in Kadriorg", description: "A luxurious 4-bedroom villa with a spacious garden.", price: 200000, images: [], type: "Sale", square_meters: 250, location: "Kadriorg, Tallinn, Estonia", rooms: 4, floor: 2, total_floors: 3, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kadriorg", street: "Vana", user_id: 1, phone_number: "372 0000 1111"},
    %{title: "Cozy Cottage in Annelinn", description: "A charming 3-bedroom cottage with a peaceful environment.", price: 900, images: [], type: "Rent", square_meters: 85, location: "Annelinn, Tartu, Estonia", rooms: 3, floor: 1, total_floors: 1, reference: nil, state: "Available", country: "Estonia", city: "Tartu", area: "Annelinn", street: "Kaunase", user_id: 1, phone_number: "372 0000 2222"},
    %{title: "Charming Apartment in Kesklinn", description: "A charming 2-bedroom apartment with a view of the park.", price: 190000, images: [], type: "Sale", square_meters: 70, location: "Kesklinn, Tallinn, Estonia", rooms: 2, floor: 2, total_floors: 5, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kesklinn", street: "Vabaduse", user_id: 1, phone_number: "372 0000 3333"},
    %{title: "Spacious 3-Bedroom in Kadriorg", description: "A spacious 3-bedroom apartment located in the heart of Kadriorg.", price: 200000, images: [], type: "Sale", square_meters: 120, location: "Kadriorg, Tallinn, Estonia", rooms: 3, floor: 3, total_floors: 5, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kadriorg", street: "Lai", user_id: 1, phone_number: "372 0000 4444"},
    %{title: "Modern Studio in Kesklinn", description: "A modern studio apartment perfect for singles or couples.", price: 950, images: [], type: "Rent", square_meters: 40, location: "Kesklinn, Tallinn, Estonia", rooms: 1, floor: 1, total_floors: 5, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kesklinn", street: "Narva mnt", user_id: 1, phone_number: "372 0000 5555"},
    %{title: "Family Home in Auranranta", description: "A large family home in a peaceful neighborhood by the river.", price: 198000, images: [], type: "Sale", square_meters: 200, location: "Auranranta, Turku, Finland", rooms: 5, floor: 2, total_floors: 2, reference: nil, state: "Available", country: "Finland", city: "Turku", area: "Auranranta", street: "Jokikatu", user_id: 1, phone_number: "372 0000 6666"},
    %{title: "Penthouse in Kesklinn", description: "Luxurious penthouse with a stunning view over Tallinn.", price: 195000, images: [], type: "Sale", square_meters: 150, location: "Kesklinn, Tallinn, Estonia", rooms: 3, floor: 5, total_floors: 5, reference: nil, state: "Available", country: "Estonia", city: "Tallinn", area: "Kesklinn", street: "Pärnu mnt", user_id: 1, phone_number: "372 0000 7777"},
    %{title: "Sunny Apartment in Pärnu", description: "A cozy 2-bedroom apartment with sunny views of Pärnu beach.", price: 210000, images: [], type: "Rent", square_meters: 70, location: "Mereäärne, Pärnu, Estonia", rooms: 2, floor: 2, total_floors: 4, reference: nil, state: "Available", country: "Estonia", city: "Pärnu", area: "Mereäärne", street: "Ranna puiestee", user_id: 1, phone_number: "372 0000 8888"},
    %{title: "Lakeview Villa in Pärnu", description: "A beautiful 4-bedroom lakeview villa in Pärnu.", price: 215000, images: [], type: "Sale", square_meters: 220, location: "Kesklinn, Pärnu, Estonia", rooms: 4, floor: 2, total_floors: 3, reference: nil, state: "Available", country: "Estonia", city: "Pärnu", area: "Kesklinn", street: "Jõe", user_id: 1, phone_number: "372 0000 9999"},
    %{title: "Beachfront Cottage in Pärnu", description: "A charming 2-bedroom beachfront cottage.", price: 960, images: [], type: "Rent", square_meters: 85, location: "Mereäärne, Pärnu, Estonia", rooms: 2, floor: 1, total_floors: 1, reference: nil, state: "Available", country: "Estonia", city: "Pärnu", area: "Mereäärne", street: "Liiva", user_id: 1, phone_number: "372 0000 1000"},
    %{title: "Luxury Flat in Punavuori", description: "A stylish 3-bedroom apartment in the vibrant district of Punavuori.", price: 350000, images: [], type: "Sale", square_meters: 120, location: "Punavuori, Helsinki, Finland", rooms: 3, floor: 2, total_floors: 5, reference: nil, state: "Available", country: "Finland", city: "Helsinki", area: "Punavuori", street: "Albertinkatu", user_id: 2, phone_number: "372 0000 1100"},
    %{title: "Cozy Apartment in Kallio", description: "A cozy apartment perfect for city living.", price: 880, images: [], type: "Rent", square_meters: 60, location: "Kallio, Helsinki, Finland", rooms: 2, floor: 2, total_floors: 5, reference: nil, state: "Available", country: "Finland", city: "Helsinki", area: "Kallio", street: "Hämeentie", user_id: 2, phone_number: "372 0000 1200"},
    %{title: "Spacious Loft in Turku", description: "A spacious loft apartment in a vibrant city center.", price: 190000, images: [], type: "Sale", square_meters: 130, location: "Kauppi, Turku, Finland", rooms: 2, floor: 3, total_floors: 5, reference: nil, state: "Available", country: "Finland", city: "Turku", area: "Kauppi", street: "Yliopistonkatu", user_id: 2, phone_number: "372 0000 1300"},
    %{title: "Luxury Apartment in Turku", description: "A luxurious 4-bedroom apartment with a river view.", price: 600000, images: [], type: "Sale", square_meters: 250, location: "Auranranta, Turku, Finland", rooms: 4, floor: 3, total_floors: 5, reference: nil, state: "Available", country: "Finland", city: "Turku", area: "Auranranta", street: "Aurakatu", user_id: 2, phone_number: "372 0000 1400"},
]


Enum.each(ads, fn ads_data ->
  # Check if the advertisement already exists by title (or another unique field)
  case Repo.get_by(Advertisement, title: ads_data.title) do
    nil ->
      # If the advertisement doesn't exist, create a changeset and insert
      %Advertisement{}
      |> Advertisement.changeset(ads_data)
      |> Repo.insert!()
      IO.puts("Inserted: #{ads_data.title}")

    _existing_ad ->
      IO.puts("Skipped (already exists): #{ads_data.title}")
  end
end)
