import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :proptrackr, Proptrackr.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  database: "proptrackr_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :proptrackr, ProptrackrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "TN+QQiRJkp09LrumKLwPE+vswxCimjpyfpUOeFV7ploOGhB+6txkzoruV4kri6Dx",
  server: true

# In test we don't send emails
config :proptrackr, Proptrackr.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :hound, driver: "chrome_driver", port: 50163
config :proptrackr, sql_sandbox: true
