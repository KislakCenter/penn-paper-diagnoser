# Records the golden master from the current code and Ruby.
# Usage (run on the Ruby version you trust, BEFORE upgrading):
#   RBENV_VERSION=3.1.2 bundle exec ruby script/record_golden_master.rb
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
ENV['RACK_ENV'] = 'test'
root = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(root)
require 'bundler/setup'
require_relative '../spec/support/golden_master'

data = { 'ruby' => RUBY_VERSION, 'results' => GoldenMaster.record(GoldenMaster.app) }
File.write(GoldenMaster::FIXTURE, JSON.pretty_generate(data))
puts "Recorded #{data['results'].size} scenarios on Ruby #{RUBY_VERSION}"
