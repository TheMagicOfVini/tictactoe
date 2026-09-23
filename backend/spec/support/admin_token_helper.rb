# frozen_string_literal: true

module AdminTokenHelper
  ADMIN_TOKEN = 'test-admin-token'

  # Sets ENV['ADMIN_TOKEN'] for the block and restores the old value after it.
  def with_admin_token(value)
    old = ENV['ADMIN_TOKEN']
    value.nil? ? ENV.delete('ADMIN_TOKEN') : ENV['ADMIN_TOKEN'] = value
    yield
  ensure
    old.nil? ? ENV.delete('ADMIN_TOKEN') : ENV['ADMIN_TOKEN'] = old
  end
end
