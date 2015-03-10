require File.expand_path('../boot', __FILE__)


require 'rails/all'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Timezone::Configure.begin do |c|
  c.username = 'twonoo'
end

module Twonoo
  class Application < Rails::Application

    Obscenity.configure do |config|
      config.blacklist   = File.join(Rails.root, 'config', 'profanity.yml')
      config.replacement = :default
    end

    config.active_job.queue_adapter = :sidekiq

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Mountain Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.before_configuration do

      file_path = File.join(Rails.root, 'config', 'local_env.yml')
      yaml_file = YAML.load_file(file_path)[Rails.env]
      yaml_file.each do |key, value|

        if value.is_a? Hash
          value.each do |nested_key, nested_value|
            ENV["#{key}_#{nested_key}"] = nested_value
          end
        else
          ENV[key] = value
        end

      end if File.exists?(file_path)

    end
  end
end
