module Firebase
  module Auth
    class IDToken
      class Error
        class ProjectIdNotSet < StandardError ; end
        class Expired < StandardError ; end
        class CannotDecode < StandardError ; end
        class IncorrectAlgorithm < StandardError ; end
        class InvalidIat < StandardError ; end
        class InvalidAud < StandardError ; end
        class InvalidIssuer < StandardError ; end
        class InvalidSub < StandardError ; end
        class InvalidAuthTime < StandardError ; end
      end
    end
  end
end
