require 'faraday'
require 'gcm_middleware/version'
require 'gcm_middleware/canonical_id'

module GCMMiddleware
  autoload :Authentication, 'gcm_middleware/authentication'

  if Faraday::Middleware.respond_to? :register_middleware
    Faraday::Request.register_middleware \
      :gcm_authentication    => lambda { Authentication }
  end
end

require 'faraday_middleware/backwards_compatibility'
