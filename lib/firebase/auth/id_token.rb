require 'firebase/auth/id_token/version'
require 'firebase/auth/id_token/config'
require 'firebase/auth/id_token/errors'
require 'jwt'

module Firebase
  module Auth
    class IDToken

      class << self
        def configure
          yield config
        end

        def config
          @config ||= Config.new
        end
      end

      def initialize(token)
        @token = token
        raise Error::ProjectIdNotSet.new('project_id is not set, please set') unless self.class.config.project_id
      end

      def verify!
        decode!
        verify_decoded_token!

        [@payload, @header]
      end

      private

      # https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library
      def decode!
        @payload, @header =
          JWT.decode(@token, nil, true,
                     {
                       verify_aud: true,
                       aud: self.class.config.project_id,
                       verify_iss: true,
                       iss: iss,
                       verify_iat: true,
                       verify_sub: true,
                       algorithms: ['RS256'],
                       jwks: jwks
                     }
                    )
      rescue JWT::ExpiredSignature => e
        raise Error::Expired.new(e.message)
      rescue JWT::IncorrectAlgorithm => e
        raise Error::IncorrectAlgorithm.new(e.message)
      rescue JWT::InvalidIatError => e
        raise Error::InvalidIat.new(e.message)
      rescue JWT::InvalidAudError => e
        raise Error::InvalidAud.new(e.message)
      rescue JWT::InvalidIssuerError => e
        raise Error::InvalidIssuer.new(e.message)
      rescue JWT::DecodeError => e
        raise Error::CannotDecode.new(e.message)
      end

      def verify_decoded_token!
        raise Error::InvalidSub.new('Subject Claim should not be empty') if !@payload['sub'] || @payload['sub'] == ''
        raise Error::InvalidAuthTime.new('Auth Time is lacking') unless @payload['auth_time']
        raise Error::InvalidAuthTime.new('Auth Time is in future') if Time.now <= Time.at(@payload['auth_time'])
      end

      def iss
        "https://securetoken.google.com/#{self.class.config.project_id}"
      end

      def jwks
        # TODO: Implement
      end
    end
  end
end
