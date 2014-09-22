require 'faraday'

module GCMMiddleware
  class Authentication < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @key = options.fetch(:key, '')

      raise ArgumentError.new('No api key was provided') if @key.nil? || @key.empty?
    end

    def call(env)
      env.request_headers['Authorization'] = auth_key

      @app.call(env).on_complete { |env| }
    end

    private

    attr_reader :key

    def auth_key
      @auth_key ||= "key=#{key}".freeze
    end
  end
end
