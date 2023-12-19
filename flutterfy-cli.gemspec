# frozen_string_literal: true

require_relative "lib/f/automation/version"

Gem::Specification.new do |spec|
  spec.name = "flutterfy-cli"
  spec.version = F::Automation::VERSION
  spec.authors = ["Cesar Ferreira"]
  spec.email = ["cesar.manuel.ferreira@gmail.com"]

  spec.summary = "Flutter CLI tool to increase development speed"
  spec.description = "Flutter CLI tool to increase development speed by automating common tasks"
  spec.homepage = "https://cesarferreira.com"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
