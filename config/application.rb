require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyLedger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    auto_load_dirs = Dir[
      "#{config.root}/lib/**/"
    ]
    config.autoload_paths += auto_load_dirs
    config.eager_load_paths += auto_load_dirs
  end
end
