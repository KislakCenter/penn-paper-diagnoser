# Smoke tests against a real, running instance of the app (rackup/Puma on a
# local port). These confirm the app boots on the current Ruby and serves the
# main flows; detailed output is covered by the golden master spec.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
RSpec.describe 'running app (smoke)' do
  EXPECTED = {
    book:      'The smallest available flavor is ROYAL OCTAVO  [21.0cm x 15.0cm]. '\
               '<br> The second smallest available flavor is SUPER-ROYAL OCTAVO  [22.5cm x 15.0cm].'\
               '<br><br>H/W ratio: 1.4 [reciprocal: 0.71]',
    landscape: 'The smallest available flavor is ROYAL HALF SHEET (landscape)  [30.0cm x 42.0cm]. '\
               '<br> The second smallest available flavor is SUPER-ROYAL HALF SHEET (landscape)  [30.0cm x 45.0cm].'\
               '<br><br>H/W ratio: 0.75 [reciprocal: 1.33]'
  }.freeze

  before(:all) { @app = RunningApp.start }
  after(:all)  { @app.stop }

  let(:app) { @app }

  def result_text(res)
    res.body[%r{<strong>Result:</strong> (.*?)</p>}m, 1]
  end

  it 'boots under Puma' do
    expect(app.output).to match(/Puma/i)
  end

  it 'GET / serves the form' do
    res = app.get('/')
    expect(res.code).to eq('200')
    expect(res.body).to include('name="paper_height"', 'name="paper_width"', 'name="object_type"')
  end

  it 'serves static assets' do
    expect(app.get('/css/styles_dtm.css').code).to eq('200')
  end

  it 'returns 404 for unknown routes' do
    expect(app.get('/nope').code).to eq('404')
  end

  it 'POST /sizeit: book leaf, no chain lines or deckles' do
    res = app.post('/sizeit', 'paper_height' => '21', 'paper_width' => '15', 'object_type' => 'bound')
    expect(res.code).to eq('200')
    expect(result_text(res)).to eq(EXPECTED[:book])
  end

  it 'POST /sizeit: single sheet, landscape' do
    res = app.post('/sizeit', 'paper_height' => '30', 'paper_width' => '40', 'object_type' => 'single')
    expect(res.code).to eq('200')
    expect(result_text(res)).to eq(EXPECTED[:landscape])
  end

  it 'POST /sizeit: both chain-line boxes asks the user to pick one' do
    res = app.post('/sizeit', 'paper_height' => '21', 'paper_width' => '15', 'object_type' => 'bound',
                              'chainlinesv' => 'checkd', 'chainlinesh' => 'checkd')
    expect(result_text(res)).to eq('Please check either Vertical or Horizontal for the chain lines.')
  end

  it 'POST /sizeit: nothing fits' do
    res = app.post('/sizeit', 'paper_height' => '100', 'paper_width' => '100', 'object_type' => 'bound')
    expect(result_text(res)).to start_with('No known flavors match your description.')
  end

  # QUIRK: known bug (get_results returns a String that app.rb calls .format
  # on). Pins the current failure; remove or flip if the bug is fixed.
  it 'QUIRK: POST /sizeit returns 500 for equal-area both-deckle input' do
    res = app.post('/sizeit', 'paper_height' => '17.5', 'paper_width' => '0', 'object_type' => 'bound',
                              'top' => 'checkd', 'bottom' => 'checkd', 'right' => 'checkd')
    expect(res.code).to eq('500')
  end
end
