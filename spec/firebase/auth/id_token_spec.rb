require 'securerandom'
require 'webrick/https'

RSpec.describe Firebase::Auth::IDToken do
  let(:project_id) { 'project-id' }

  describe '#verify!' do
    let(:cert_and_rsa) { WEBrick::Utils.create_self_signed_cert(2048, '', '') }
    let(:certificate) { cert_and_rsa[0] }
    let(:rsa_key) { cert_and_rsa[1] }
    let(:kid) { SecureRandom.hex }
    let(:alg) { 'RS256' }
    let(:auth_time) { (Time.now - 60).to_i }
    let(:iat) { Time.now.to_i }
    let(:exp) { (Time.now + 60).to_i }
    let(:aud) { project_id }
    let(:iss) { "https://securetoken.google.com/#{project_id}" }
    let(:sub) { SecureRandom.hex }
    let(:payload) do
      {
         "iss"=>iss,
         "aud"=>aud,
         "auth_time"=>auth_time,
         "user_id"=>sub,
         "sub"=>sub,
         "iat"=>iat,
         "exp"=>exp,
         "email"=>"takehiro0740@gmail.com",
         "email_verified"=>false,
         "firebase"=>{"identities"=>{"email"=>["takehiro0740@gmail.com"]}, "sign_in_provider"=>"password"}
      }
    end
    let(:header) do
      {
        "alg" => alg,
        "kid" => kid,
      }
    end
    let(:token) { JWT.encode(payload, rsa_key, alg, header) }

    before do
      allow_any_instance_of(Firebase::Auth::IDToken::PublicKeys).to(
        receive(:public_keys_from_remote).and_return({ kid.to_s => certificate.to_pem })
      )
    end

    context 'when #config#project_id is not set' do
      it 'raises Firebase::Auth::IDToken::Error::ProjectIdNotSet' do
        expect {
          described_class.new(token).verify!
        }.to raise_error(Firebase::Auth::IDToken::Error::ProjectIdNotSet)
      end
    end

    context 'when #config#project_id is set' do
      before do
        Firebase::Auth::IDToken.configure do |config|
          config.project_id = project_id
        end
      end

      context 'when the given ID token' do
        context 'has no problem' do
          it 'returns payload and header' do
            payload_res, header_res = described_class.new(token).verify!

            expect(payload_res).to eq payload
            expect(header_res).to eq header
          end
        end

        context 'is not encoded with RS256 algorithm' do
          let(:alg) { 'RS512' }

          it 'raises Firebase::Auth::IDToken::Error::IncorrectAlgorithm' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::IncorrectAlgorithm)
          end
        end

        context 'is expired' do
          let(:exp) { (Time.now - 60).to_i }

          it 'raises Firebase::Auth::IDToken::Error::Expired' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::Expired)
          end
        end

        context 'is issued in the future' do
          let(:iat) { (Time.now + 60).to_i }

          it 'raises Firebase::Auth::IDToken::Error::InvalidIat' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidIat)
          end
        end

        context 'does not have the correct aud' do
          let(:aud) { 'invalid aud' }

          it 'raises Firebase::Auth::IDToken::Error::InvalidAud' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidAud)
          end
        end

        context 'does not have the correct iss' do
          let(:iss) { 'invalid iss' }

          it 'raises Firebase::Auth::IDToken::Error::InvalidIssuer' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidIssuer)
          end
        end

        context 'does not have sub' do
          let(:token) do
            payload.delete('sub')
            JWT.encode(payload, rsa_key, alg, header)
          end

          it 'raises Firebase::Auth::IDToken::Error::InvalidSub' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidSub)
          end
        end

        context 'sub is empty string' do
          let(:sub) { '' }

          it 'raises Firebase::Auth::IDToken::Error::InvalidSub' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidSub)
          end
        end

        context 'auth time is future' do
          let(:auth_time) { (Time.now + 60).to_i }

          it 'raises Firebase::Auth::IDToken::Error::InvalidAuthTime' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidAuthTime)
          end
        end

        context 'auth time is not present' do
          let(:token) do
            payload.delete('auth_time')
            JWT.encode(payload, rsa_key, alg, header)
          end

          it 'raises Firebase::Auth::IDToken::Error::InvalidAuthTime' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::InvalidAuthTime)
          end
        end

        context 'cannot be decoded' do
          let(:token) { 'invalid token' }

          it 'raises Firebase::Auth::IDToken::Error::CannotDecode' do
            expect {
              described_class.new(token).verify!
            }.to raise_error(Firebase::Auth::IDToken::Error::CannotDecode)
          end
        end
      end
    end
  end
end
