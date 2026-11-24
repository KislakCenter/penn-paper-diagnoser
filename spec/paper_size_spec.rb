# Characterization tests: pin CURRENT PaperSize behavior to detect changes
# across a Ruby upgrade.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
RSpec.describe PaperSize do
  describe 'dimensions [height, width] in cm for imperial (48.0 x 34.0)' do
    {
      folio:         [48.0, 34.0],
      agenda_quarto: [48.0, 17.0],
      quarto:        [34.0, 24.0],
      octavo:        [24.0, 17.0],
      sixteen_mo:    [17.0, 12.0],
      thirtytwo_mo:  [12.0, 8.5],
      sixtyfour_mo:  [8.5,  6.0],
      full_sheet:    [68.0, 48.0]
    }.each do |format, (h, w)|
      it "#{format} is #{h} x #{w}" do
        ps = described_class.new(:imperial, format)
        expect([ps.height, ps.width]).to eq([h, w])
        expect(ps.area).to eq((h * w).round(1))
      end
    end
  end

  it 'rounds derived dimensions to one decimal' do
    ps = described_class.new(:half_median, :sixtyfour_mo) # 17.5/4, 25/8
    expect([ps.height, ps.width, ps.area]).to eq([4.4, 3.1, 13.6])
  end

  it 'defines all 8 categories' do
    expect(described_class::UNTRIMDIMS.keys).to eq(
      %i(imperial super_royal royal super_median median super_chancery chancery half_median)
    )
  end

  describe '#measure' do
    let(:ps) { described_class.new(:royal, :folio) }

    it { expect(ps.measure(:h)).to eq(42.0) }
    it { expect(ps.measure(:w)).to eq(30.0) }
    it { expect(ps.measure(:a)).to eq(1260.0) }
    it { expect(ps.measure(:x)).to be_nil }
  end

  describe '#==' do
    it 'compares category and format' do
      expect(described_class.new(:royal, :folio)).to eq(described_class.new(:royal, :folio))
      expect(described_class.new(:royal, :folio)).not_to eq(described_class.new(:royal, :octavo))
      expect(described_class.new(:royal, :folio)).not_to eq(described_class.new(:median, :folio))
      expect(described_class.new(:royal, :folio)).not_to eq('ROYAL FOLIO')
    end
  end

  describe '#to_s and #dimensions' do
    let(:ps) { described_class.new(:imperial, :folio) }

    it 'formats a book leaf' do
      expect(ps.to_s).to eq('IMPERIAL FOLIO  [48.0cm x 34.0cm]')
    end

    it 'formats a single sheet in portrait' do
      $single = true
      expect(ps.to_s).to eq('IMPERIAL HALF SHEET (portrait)  [48.0cm x 34.0cm]')
    end

    it 'formats a single sheet in landscape, swapping dimensions' do
      $single = true
      $landsc = true
      expect(ps.to_s).to eq('IMPERIAL HALF SHEET (landscape)  [34.0cm x 48.0cm]')
    end

    it 'uses alternate single-sheet names' do
      $single = true
      names = %i(full_sheet folio agenda_quarto quarto octavo sixteen_mo thirtytwo_mo sixtyfour_mo)
              .map { |f| described_class.new(:median, f).to_s[/\A\S+ (.*?) \(/, 1] }
      expect(names).to eq(
        ['FULL SHEET', 'HALF SHEET', 'AGENDA QUARTER SHEET', 'QUARTER SHEET',
         'EIGHTH SHEET', '16th SHEET', '32th SHEET', '64th SHEET']
      )
    end
  end
end
