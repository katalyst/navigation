# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "katalyst-navigation"
  spec.version = "1.8.1"
  spec.authors = ["Katalyst Interactive"]
  spec.email = ["developers@katalyst.com.au"]

  spec.summary = "Navigation generator and editor"
  spec.homepage = "https://github.com/katalyst/navigation"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.files = Dir["{app,config,db,lib/katalyst}/**/*", "spec/factories/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "katalyst-html-attributes"
  spec.add_dependency "katalyst-kpop"
  spec.add_dependency "katalyst-tables"
  spec.add_dependency "view_component"
end
