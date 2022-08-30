# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(spec: "app:db:prepare")

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
