# frozen_string_literal: true

# Parses the CORS_ORIGINS environment variable into a list of allowed origins.
#
# This file lives in backend/lib, not backend/app/lib. The app runs Rails 5.2
# with the classic autoloader. An initializer that references an autoloaded
# constant can break on code reload in development, so config/initializers/cors.rb
# loads this file with an explicit require instead of relying on autoloading.
class CorsOrigins
  # Raised when CORS_ORIGINS is missing or blank in production.
  class MissingOriginsError < StandardError; end

  DEFAULT_ORIGIN = 'http://localhost:3000'

  # env: a hash with a "CORS_ORIGINS" key, such as ENV.
  # rails_env: a string, such as "development", "test" or "production".
  def self.list(env, rails_env)
    origins = parse(env['CORS_ORIGINS'])

    if rails_env == 'production'
      raise_missing_origins if origins.empty?
      return origins
    end

    origins.empty? ? [DEFAULT_ORIGIN] : origins
  end

  # Splits a comma-separated string. Trims each entry. Drops empty entries.
  def self.parse(raw)
    return [] if raw.nil?

    raw.split(',').map(&:strip).reject(&:empty?)
  end

  def self.raise_missing_origins
    raise MissingOriginsError,
          'CORS_ORIGINS must be set in production. Set it to a comma-separated list of allowed origins.'
  end
  private_class_method :raise_missing_origins
end
