describe GCMMiddleware::Authentication do
  let(:faraday) do
    Faraday.new('http://www.example.com') do |builder|
      builder.use GCMMiddleware::Authentication, key: auth_key

      builder.adapter :test do |stub|
        stub.get('/test') { |env| [ 200, {}, {} ] }
      end
    end
  end

  context 'with auth key' do
    let(:auth_key) { 'auth-key' }

    it 'injects the key into the header' do
      response = faraday.get '/test'

      expect(response.env.request_headers['Authorization']).to eq('key=auth-key')
    end
  end

  context 'with no auth key' do
    context 'with nil auth key' do
      let(:auth_key) { nil }

      it 'throws a error if no api key is provided' do
        expect {
          faraday.get '/test'
        }.to raise_error(ArgumentError, 'No api key was provided')
      end
    end

    context 'with empty api key' do
      let(:auth_key) { '' }

      it 'throws a error if no api key is provided' do
        expect {
          faraday.get '/test'
        }.to raise_error(ArgumentError, 'No api key was provided')
      end
    end
  end
end
