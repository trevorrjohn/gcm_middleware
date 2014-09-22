require 'faraday'

module GCMMiddleware
  class CanonicalId < Faraday::Middleware
    def call(env)
      save_ids(env.body)

      @app.call(env).on_complete do |env|
        inject_original_ids(env.body) if has_registration_ids && env.body
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

    def has_registration_ids
      registration_ids && registration_ids.any?
    end
  end
end
