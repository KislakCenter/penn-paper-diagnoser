ENV['RACK_ENV'] = 'test'
ROOT = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(ROOT)

require 'bundler/setup'
require 'lib/diagnoser'
require 'lib/flavortranslate'
Dir[File.join(__dir__, 'support', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # The app and PaperSize communicate through globals; isolate every example.
  config.before(:each) { $single = false; $landsc = false }
  config.order = :defined
end
