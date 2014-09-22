require 'faraday'

module GCMMiddleware
  class CanonicalId < Faraday::Middleware
    GCM_PATH = '/gcm/send'.freeze
    def call(env)
      save_ids(env.body) if is_gcm_url?(env.url)

      @app.call(env).on_complete do |env|
        inject_original_ids(env.body) if should_inject_ids?(env)
      end
    end

    private

    attr_reader :registration_ids

    def inject_original_ids(body)
      body['results'].each_with_index do |result, i|
        result['original_id'] = registration_ids[i]
      end
    end

    def save_ids(body)
      @registration_ids = body.fetch('registration_ids', []) if body
    end

    def should_inject_ids?(env)
      is_success?(env.status) &&
        is_gcm_url?(env.url) &&
        has_registration_ids?
    end

    def has_registration_ids?
      registration_ids && registration_ids.any?
    end


    def is_success?(status)
      status == 200
    end

    def is_gcm_url?(url)
      url.path == GCM_PATH
    end
  end
end
