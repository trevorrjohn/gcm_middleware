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

  context 'canonical id' do
    let(:faraday) do
      Faraday.new('http://www.example.com') do |f|
        f.use :gcm_canonical_id

        f.adapter :test do |stub|
          stub.post('/test') { |env| [ 200, {}, {'results' => [{}]} ] }
        end
      end
    end

    it 'registers :gcm_canonical_id' do
      response = faraday.post('test', { 'registration_ids' => ['1'] })

      expect(response.body['results'][0]['original_id']).to eq '1'
    end
  end
end
