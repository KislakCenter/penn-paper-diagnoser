require 'json'
require 'rack/mock'

# Builds the grid of POST /sizeit requests used as the golden master and runs
# them against the Sinatra app, capturing each response body (or the class of
# any exception raised).
#
# The recorded fixture (spec/fixtures/golden_master.json) captures CURRENT
# behavior, including known bugs. It exists to detect any change in output
# across a Ruby upgrade; it is not a statement that the output is correct.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
module GoldenMaster
  ROOT    = File.expand_path('../..', __dir__)
  FIXTURE = File.expand_path('fixtures/golden_master.json', File.dirname(__dir__))

  HEIGHTS = [0, 8.5, 12.0, 17.5, 24.0, 31.5, 48.1].freeze
  WIDTHS  = [0, 11.5, 15.0, 17.0, 23.0, 34.0].freeze
  CHAINS  = [nil, :v, :h, :both].freeze
  OBJECTS = %w(bound single).freeze
  DECKLES = %w(top bottom right left).freeze

  # Loads the classic-style Sinatra app without starting a server.
  #
  # @return [Class] Sinatra::Application
  def self.app
    $LOAD_PATH.unshift(ROOT) unless $LOAD_PATH.include?(ROOT)
    require 'sinatra'
    Sinatra::Application.set :run, false
    Sinatra::Application.set :root, ROOT
    require File.join(ROOT, 'app')
    Sinatra::Application
  end

  # @return [Array<Hash>] every combination of inputs, as POST params
  def self.scenarios
    deckle_sets = (0..DECKLES.size).flat_map { |n| DECKLES.combination(n).to_a }
    HEIGHTS.product(WIDTHS, CHAINS, OBJECTS, deckle_sets).map do |h, w, chain, obj, decks|
      params = { 'paper_height' => h.to_s, 'paper_width' => w.to_s, 'object_type' => obj }
      params['chainlinesv'] = 'checkd' if %i(v both).include?(chain)
      params['chainlinesh'] = 'checkd' if %i(h both).include?(chain)
      decks.each { |d| params[d] = 'checkd' }
      params
    end
  end

  # @param params [Hash] form params
  # @return [String] stable key for the scenario
  def self.key(params)
    params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  # @param app [#call] the Rack app
  # @param params [Hash] form params
  # @return [String] response body, or "ERROR: ClassName" if the app raised
  def self.run(app, params)
    res = Rack::MockRequest.new(app).post('/sizeit', params: params)
    "#{res.status} #{res.body}"
  rescue StandardError => e
    "ERROR: #{e.class}"
  end

  # @return [Hash{String=>String}] key => output for every scenario
  def self.record(app)
    scenarios.to_h { |p| [key(p), run(app, p)] }
  end
end
