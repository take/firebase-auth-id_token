require_relative 'lib/firebase/auth/id_token/version'

Gem::Specification.new do |spec|
  spec.name          = "firebase-auth-id_token"
  spec.version       = Firebase::Auth::IDToken::VERSION
  spec.authors       = ["Takehiro Adachi"]
  spec.email         = ["takehiro0740@gmail.com"]

  spec.summary       = %q{Small gem which verifies your firebase auth ID token in server side}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/take/firebase-auth-id_token"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/take/firebase-auth-id_token/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end