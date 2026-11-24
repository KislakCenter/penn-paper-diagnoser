# Compares POST /sizeit output for a large grid of inputs with output recorded
# on the pre-upgrade Ruby. Any difference means behavior changed.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
RSpec.describe 'golden master: POST /sizeit' do
  app      = GoldenMaster.app
  golden   = JSON.parse(File.read(GoldenMaster::FIXTURE))
  recorded = golden['results']

  it 'covers the same scenarios that were recorded' do
    keys = GoldenMaster.scenarios.map { |p| GoldenMaster.key(p) }
    expect(keys).to match_array(recorded.keys)
  end

  it "matches output recorded on Ruby #{golden['ruby']}" do
    current = GoldenMaster.scenarios.to_h do |p|
      [GoldenMaster.key(p), GoldenMaster.run(app, p)]
    end
    diffs = current.reject { |k, v| recorded[k] == v }
    expect(diffs.size).to eq(0), lambda {
      diffs.first(5).map { |k, v| "#{k}\n  was: #{recorded[k]}\n  now: #{v}" }.join("\n")
    }
  end
end
