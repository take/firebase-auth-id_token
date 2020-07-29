RSpec.describe Firebase::Auth::IDToken::PublicKeys do
  describe '#initialize' do
    context 'when the endpoint returns 200' do
      it 'sets public keys in self' do
        VCR.use_cassette('v1_x509_public_keys_success') do
          public_keys = described_class.new

          expect(public_keys.first.class).to eq Firebase::Auth::IDToken::PublicKey
        end
      end
    end

    context 'when the endpoint returns 500' do
      it 'raises Firebase::Auth::IDToken::PublicKeys::FailedToFetchFromRemote' do
        VCR.use_cassette('v1_x509_public_keys_failure') do
          expect {
            described_class.new
          }.to raise_error(Firebase::Auth::IDToken::PublicKeys::FailedToFetchFromRemote)
        end
      end
    end
  end

  describe '#find_by!' do
    let(:public_keys) { described_class.new }

    context 'when the corresponding public key exists' do
      let(:kid) { 'fajewofaefahleiuhfaluihf984761987hfaeufh' }

      it 'returns it' do
        VCR.use_cassette('v1_x509_public_keys_success') do
          expect(public_keys.find_by!(kid: kid).class).to eq Firebase::Auth::IDToken::PublicKey
        end
      end
    end

    context 'when the corresponding public key does not exist' do
      let(:kid) { 'invalid kid' }

      it 'raises Firebase::Auth::IDToken::PublicKeys::NotFound' do
        VCR.use_cassette('v1_x509_public_keys_success') do
          expect { public_keys.find_by!(kid: kid) }.to raise_error(Firebase::Auth::IDToken::PublicKeys::NotFound)
        end
      end
    end
  end
end
