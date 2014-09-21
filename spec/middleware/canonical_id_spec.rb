describe GCMMiddleware::CanonicalId do
  let(:faraday) do
    Faraday.new('http://www.example.com') do |builder|
      builder.use GCMMiddleware::CanonicalId

      builder.adapter :test do |stub|
        stub.post('/test') { |env| [ 200, {}, {'results' => raw_results} ] }
        stub.post('/error') { |env| [ 200, {}, nil ] }
      end
    end
  end
  let(:raw_results) { [] }

  context 'with no body' do
    it 'does not modify request' do
      response = faraday.post '/test', nil

      expect(response.body).to eq({'results' => []})
    end
  end

  context 'when no registration ids' do
    let(:body) { {'foo' =>  'bar'} }

    it 'does nothing with the request' do
      response = faraday.post '/test', body

      expect(response.body).to eq({'results' => []})
    end
  end

  context 'with registration ids' do
    let(:raw_results) do
      [
        {
          'message_id' => 'message-1',
          'registration_id' => 'registration-1',
          'error' => nil
        },
        {
          'message_id' => 'message-2',
          'registration_id' => 'registration-2',
          'error' => nil
        }
      ]
    end
    let(:body) { {'registration_ids' => ['first-id', 'second-id']} }

    it 'stores the original ids in the response' do
      response = faraday.post '/test', body

      results = response.body['results']
      expect(results[0]).to eq({
          'message_id' => 'message-1',
          'registration_id' => 'registration-1',
          'error' => nil,
          'original_id' => 'first-id'
      })
      expect(results[1]).to eq({
          'message_id' => 'message-2',
          'registration_id' => 'registration-2',
          'error' => nil,
          'original_id' => 'second-id'
      })
    end

    context 'with no response body' do
      it 'does not throw exception' do
        response = faraday.post '/error', body

        expect(response.body).to be_nil
      end
    end
  end
end
