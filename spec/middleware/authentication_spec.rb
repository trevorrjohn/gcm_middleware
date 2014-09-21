describe GCMMiddleware::Authentication do
  let(:faraday) do
    Faraday.new('http://www.example.com') do |builder|
      builder.use GCMMiddleware::Authentication, key: 'auth-key'

      builder.adapter :test do |stub|
        stub.get('/test') { |env| [ 200, {}, {} ] }
      end
    end
  end

  it 'injects the key into the header' do
    response = faraday.get '/test'

    expect(response.env.request_headers['Authorization']).to eq('key=auth-key')
  end
end

