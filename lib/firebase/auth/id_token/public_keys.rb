require 'json'
require 'open-uri'

module Firebase
  module Auth
    class IDToken
      class PublicKeys < Array
        PUBLIC_KEYS_URI = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
        private_constant :PUBLIC_KEYS_URI

        class NotFound < StandardError ; end
        class FailedToFetchFromRemote < StandardError ; end

        def initialize
          public_keys_from_remote.each do |kid, certificate|
            self << PublicKey.new(kid: kid, certificate: certificate)
          end
        end

        def find_by!(kid:)
          public_key = self.find { |public_key| public_key.kid == kid }

          raise NotFound unless public_key

          public_key
        end

        private

        def public_keys_from_remote
          begin
            JSON.parse(URI.open(PUBLIC_KEYS_URI).read)
          rescue OpenURI::HTTPError => e
            raise FailedToFetchFromRemote.new(e.io.status[1])
          end
        end
      end

      private

      class PublicKey
        attr_reader :kid, :certificate

        def initialize(kid:, certificate:)
          @kid = kid
          @certificate = OpenSSL::X509::Certificate.new(certificate)
        end
      end
    end
  end
end
