require 'firebase/auth/id_token/version'
require 'firebase/auth/id_token/config'

module Firebase
  module Auth
    module IDToken
      class Error < StandardError; end

      class << self
        def configure
          yield config
        end

        def config
          @config ||= Config.new
        end
      end
    end
  end
end
