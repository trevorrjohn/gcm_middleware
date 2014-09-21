module GCMMiddleware
  class Authentication
    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      env.request_headers['Authorization'] = auth_key

      app.call(env).on_complete { |env| }
    end

    private

    attr_reader :app, :options

    def auth_key
      @auth_key ||= "key=#{options[:key]}".freeze
    end
  end
end
