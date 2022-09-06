# frozen_string_literal: true

require_relative "lib/katalyst/navigation/version"

Gem::Specification.new do |spec|
  spec.name = "katalyst-navigation"
  spec.version = Katalyst::Navigation::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email = ["developers@katalyst.com.au"]

  spec.summary = "Navigation generator and editor"
  spec.homepage = "https://github.com/katalyst/navigation"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
