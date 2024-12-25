defmodule ProptrackrWeb.Router do
  use ProptrackrWeb, :router

  # Browser pipeline
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProptrackrWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # API pipeline
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Authentication pipeline
  pipeline :browser_auth do
    plug Proptrackr.AuthPipeline
  end

  # Ensure authentication pipeline (requires user to be authenticated)
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # Admin access pipeline (requires user to be an admin)
  pipeline :is_admin do
    plug ProptrackrWeb.Admin
  end

  # Public routes (without authentication)
  scope "/", ProptrackrWeb do
    pipe_through [:browser, :browser_auth]

    get "/register", SessionController, :register
    post "/register", SessionController, :registerUser
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    get "/search", PageController, :search

    resources "/advertisements", AdvertisementController
    post "/advertisements/:id/update_sold", AdvertisementController, :update_sold
    post "/advertisements/:id/update_reserved", AdvertisementController, :update_reserved
    post "/advertisements/:id/update_available", AdvertisementController, :update_available

    get "/advertisements/not_interested/:advertisement_id/:user_id", AdvertisementController, :not_interested
    get "/users/:id/not_interested_ads", AdvertisementController, :not_interested_ads
    delete "/advertisements/:id/remove_not_interested", AdvertisementController, :remove_not_interested
    get "/advertisements/:id/detail", AdvertisementController, :show_detail

    #get "/advertisements/favorite/:advertisement_id/:user_id", AdvertisementController, :favorite
    get "/users/:id/favorite_ads", AdvertisementController, :favorite_ads
    delete "/advertisements/:id/remove_favorite", AdvertisementController, :remove_favorite
    post "/advertisements/favorite/:advertisement_id/:user_id", AdvertisementController, :favorite

    get "/", PageController, :home

    # Public user profile route (viewable by anyone)
    get "/users/:id", UserController, :show  # Allow all users to view profiles
  end

  # Authenticated user routes (ensure the user is logged in)
  scope "/", ProptrackrWeb do
    pipe_through [:browser, :browser_auth, :ensure_auth]

    get "/users/:id/edit", UserController, :edit
    put "/users/:id/edit", UserController, :update
    get "/settings", UserController, :settings

    get "/users/:id/change_password_forum", UserController, :change_password_forum
    post "/users/:id/change_password", UserController, :change_password
    delete "/users/:id/delete", UserController, :delete

  end

  # Admin routes (ensure the user is an admin)
  scope "/", ProptrackrWeb do
    pipe_through [:browser, :browser_auth, :ensure_auth, :is_admin]

    resources "/users", UserController
    patch "/users/:id/block", UserController, :block
    get "/users/:id/admin/edit", UserController, :admin_edit
    put "/users/:id/admin/edit", UserController, :update
    delete "/users/:id/admin/delete", UserController, :delete

  end

  # Development routes (for LiveDashboard and Swoosh preview in development)
  if Application.compile_env(:proptrackr, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProptrackrWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
