RSpec.describe Authenticate::Command do

  let(:valid_data) do
    {
      apiVersion: TokenReview::API_VERSION,
      kind: TokenReview.name,
      spec: {
        token: '123'
      }
    }
  end

  context 'validation' do
    it 'passes valid json structure' do
      subject = described_class.new(valid_data)
      expect(subject.has_errors?).to be_falsey
    end
  end
end