RSpec.describe Firebase::Auth::IdToken::Verifier do
  it "has a version number" do
    expect(Firebase::Auth::IdToken::Verifier::VERSION).not_to be nil
  end

  describe '#verify!' do
    context 'when the given ID token' do
      context 'cannot be decoded by JWT' do
        xit 'raises Firebase::Auth::IDToken::InvalidToken'
      end

      context 'is expired' do
        xit 'raises Firebase::Auth::IDToken::Expired'
      end
    end
  end
end
