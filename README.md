# GcmMiddleware

[![Build Status](https://travis-ci.org/tjohn/gcm_middleware.svg?branch=master)](https://travis-ci.org/tjohn/gcm_middleware)
[![Code Climate](https://codeclimate.com/github/tjohn/gcm_middleware/badges/gpa.svg)](https://codeclimate.com/github/tjohn/gcm_middleware)

Faraday ( https://github.com/lostisland/faraday ) middleware for Google Cloud Messaging. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gcm_middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gcm_middleware

## Usage

There are two separate Middleware files, the first is for authorization and adds the request header with your api key.
The second is for storing your original device registration ids. Because GCM does not return your original id, and only returns the new canonical id. This piece will inject the original id into the response body.

```ruby
Faraday.new('https://android.googleapis.com/') do |f|
  f.request :gcm_authentication, key: '<your api key'

  f.use :gcm_canonical_id
  f.use :json
end
```

## TODO

* GCMMiddleware::CanonicalId requires the body to have been parsed into a hash. It should handle both cases where it is not already parsed, thus removing the dependency on faraday_middleware.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gcm_middleware/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
