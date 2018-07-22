RSpec.describe Github::Authenticate do
  let(:valid_data) do
    {
      apiVersion: TokenReview::API_VERSION,
      kind: TokenReview.name,
      spec: {
        token: '123'
      }
    }
  end

  describe '#execute' do
    it 'returns authenticated on valid token' do
      stub_request(:get, "https://api.github.com/user").to_return( body: { login: 'johndoe' }.to_json )
      stub_request(:get, "https://api.github.com/user/teams").to_return( body: '[]' )

      subject = described_class.new(valid_data)
      outcome = subject.run
      expect(outcome.success?).to be_truthy
      expect(outcome.result.status.authenticated).to be_truthy
      expect(outcome.result.status.user.username).to eq('johndoe')
    end

    it 'returns not authenticated on invalid token' do
      stub_request(:get, "https://api.github.com/user").to_return( status: 403 )

      subject = described_class.new(valid_data)
      outcome = subject.run
      expect(outcome.success?).to be_truthy
      expect(outcome.result.status.authenticated).to be_falsey
    end
  end
end