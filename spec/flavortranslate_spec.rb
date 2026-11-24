# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
RSpec.describe 'flavortranslate' do
  describe '#fmt_str' do
    {
      sixteen_mo:    '16mo',
      thirtytwo_mo:  '32mo',
      sixtyfour_mo:  '64mo',
      folio:         'FOLIO',
      agenda_quarto: 'AGENDA-QUARTO',
      full_sheet:    'FULL-SHEET',
      '16th sheet'   => '16th SHEET',
      '32th sheet'   => '32th SHEET',
      '64th sheet'   => '64th SHEET',
      'half sheet'   => 'HALF SHEET',
      'agenda quarter sheet' => 'AGENDA QUARTER SHEET'
    }.each do |input, expected|
      it "#{input.inspect} => #{expected.inspect}" do
        expect(fmt_str(input)).to eq(expected)
      end
    end
  end

  describe '#cat_str' do
    it { expect(cat_str(:imperial)).to eq('IMPERIAL') }
    it { expect(cat_str(:super_royal)).to eq('SUPER-ROYAL') }
    it { expect(cat_str(:half_median)).to eq('HALF-MEDIAN') }
  end
end
