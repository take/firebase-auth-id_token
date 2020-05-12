module Firebase
  module Auth
    class IDToken
      class Error
        class ProjectIdNotSet < StandardError ; end

        class VerificationFail < StandardError ; end

        class Expired < VerificationFail ; end
        class CannotDecode < VerificationFail ; end
        class IncorrectAlgorithm < VerificationFail ; end
        class InvalidIat < VerificationFail ; end
        class InvalidAud < VerificationFail ; end
        class InvalidIssuer < VerificationFail ; end
        class InvalidSub < VerificationFail ; end
        class InvalidAuthTime < VerificationFail ; end
      end
    end
  end
end
