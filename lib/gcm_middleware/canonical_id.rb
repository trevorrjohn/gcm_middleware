require 'faraday'
require 'json'

module GCMMiddleware
  class CanonicalId < Faraday::Middleware
    GCM_PATH = '/gcm/send'.freeze
    GCM_REGISTRATION_ID_KEY = 'registration_ids'.freeze
    GCM_RESULTS_KEY = 'results'.freeze
    ORIGINAL_ID_KEY = 'original_id'.freeze

    def call(env)
      save_ids(env.body) if should_save_ids?(env)

      @app.call(env).on_complete do |env|
        if should_inject_ids? env
          env.body = injected_response_body(env.body)
        end
      end
    end

    private

    attr_reader :registration_ids, :has_saved_ids

    def injected_response_body(body)
      if body.is_a? Hash
        set_ids(body)
      else
        set_ids(JSON.parse(body)).to_json
      end
    end

    def set_ids(body)
      body.tap do |b|
        b.fetch(GCM_RESULTS_KEY, []).each_with_index do |result, i|
          result[ORIGINAL_ID_KEY] = registration_ids[i]
        end
      end
    end

    def should_save_ids?(env)
      @has_saved_ids = is_gcm_url?(env.url) && env.body
    end

    def save_ids(body)
      @registration_ids = parse(body).fetch(GCM_REGISTRATION_ID_KEY, [])
    end

    def should_inject_ids?(env)
      has_saved_ids &&
        is_success?(env.status) &&
        has_registration_ids?
    end

    def has_registration_ids?
      registration_ids && registration_ids.any?
    end

    def parse(body)
      body.is_a?(String) ? JSON.parse(body) : body
    end

    def is_success?(status)
      status == 200
    end

    def is_gcm_url?(url)
      url.path == GCM_PATH
    end
  end
end
