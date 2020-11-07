# frozen_string_literal: true

#require 'rails'
require 'active_record'
require 'active_record/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MinionApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # This requires explanation. In the Rake task for migrations, it tries to access
    # an original configuration before it runs the migration. In our case, where there
    # is no actual application -- all we care about is the migrations -- this isn't
    # setup. So, even though there is no point to it, and the migration task is going
    # to make its own connection, we need to create an original connection here before
    # Rake gets to take over the action.
    # For reference, it is around like 83 of active_record/railties/databases.rake
    dbconfig = YAML::load File.read(File.join(Rails.root, "config/database.yml"))
    ActiveRecord::Base.establish_connection dbconfig[Rails.env]
  end
end
