require 'faraday'
require 'gcm_middleware/version'

module GCMMiddleware
  autoload :Authentication, 'gcm_middleware/authentication'
  autoload :CanonicalId, 'gcm_middleware/canonical_id'

  if Faraday::Middleware.respond_to? :register_middleware
    Faraday::Request.register_middleware \
      :gcm_authentication => lambda { Authentication }

    Faraday::Middleware.register_middleware \
      :gcm_canonical_id => lambda { CanonicalId }
  end
end

require 'faraday_middleware/backwards_compatibility'
