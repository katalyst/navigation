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
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
