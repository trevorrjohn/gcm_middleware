describe GCMMiddleware do
  context 'authentication' do
    let(:faraday) do
      Faraday.new('http://www.example.com') do |f|
        f.request :gcm_authentication, key: 'my-api-key'

        f.adapter :test do |stub|
          stub.get('/test') { |env| [ 200, {}, {} ] }
        end
      end
    end

    it 'registers :gcm_authentication' do
      response = faraday.get('test')
      expect(response.env.request_headers['Authorization']).to eq 'key=my-api-key'
    end
  end
end
