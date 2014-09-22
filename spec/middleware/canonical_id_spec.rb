
describe GCMMiddleware::CanonicalId do
  let(:response) { faraday.post(path, request_body) }
  let(:path) { '/gcm/send' }
  let(:status_code) { 200 }
  let(:raw_response) { {} }
  let(:response_object) { [status_code, {}, raw_response] }
  let(:faraday) do
    Faraday.new('http://www.example.com') do |builder|
      builder.use GCMMiddleware::CanonicalId

      builder.adapter :test do |stub|
        stub.post('/gcm/send') { |env| response_object }
        stub.post('/other') { |env| [ 200, {}, raw_response ] }
      end
    end
  end
  let(:request_body) { nil }

  shared_examples 'a normal request' do
    it 'does not modify request or response' do
      expect(response.body).to eq(raw_response)
    end
  end

  context 'with no request body' do
    it_behaves_like 'a normal request'
  end

  context 'when it is not the gcm path' do
    let(:path) { '/other' }
    let(:raw_response) { { 'foo' => 'bar' } }
    let(:request_body) { { 'registration_ids' => ['1'] } }

    it_behaves_like 'a normal request'
  end

  context 'when a error is thrown' do
    let(:status_code) { 500 }
    let(:request_body) { {'registration_ids' => ['1']} }

    it_behaves_like 'a normal request'
  end

  context 'with a request body' do
    context 'with no registration ids' do
      let(:body) { {'foo' =>  'bar'} }

      it_behaves_like 'a normal request'
    end

    shared_examples 'a gcm request' do
      it 'stores the original id in the results' do
        body = response.body

        results = body.is_a?(String) ? JSON.parse(body)['results'] : body['results']

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
    end

    context 'with registration ids' do
      let(:request_body) do
        {'registration_ids' => ['first-id', 'second-id']}
      end
      let(:raw_response) do
        { 'results' =>
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
        }
      end

      it_behaves_like 'a gcm request'

      context 'with json request' do
        let(:response_object) { [status_code, {}, raw_response.to_json] }
        let(:response) { faraday.post(path, request_body.to_json) }

        it_behaves_like 'a gcm request'
      end
    end
  end
end
