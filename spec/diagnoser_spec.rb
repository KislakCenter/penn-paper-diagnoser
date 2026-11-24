# Characterization tests for Diagnoser, including known quirks (marked
# "QUIRK"). Quirk tests pin today's behavior; if one fails after an upgrade,
# behavior changed.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
RSpec.describe Diagnoser do
  subject(:diagnoser) { described_class.new }

  def pairs(list)
    list.map { |ps| [ps.category, ps.format] }
  end

  def results(h, w, chain, tobo, side)
    diagnoser.find_matches(h, w, chain)
    diagnoser.sort_by_dim(:a)
    diagnoser.get_results(tobo, side)
  end

  describe '#find_matches' do
    def match_count(chain)
      diagnoser.find_matches(0, 0, chain)
      diagnoser.instance_variable_get(:@matches)
    end

    it 'considers 8 categories x 7 formats with no chain direction' do
      expect(match_count(nil).size).to eq(56)
    end

    it 'excludes quarto, 16mo, 64mo for vertical chain lines' do
      formats = match_count(:vertical).map(&:format).uniq
      expect(formats).to eq(%i(folio agenda_quarto octavo thirtytwo_mo))
    end

    it 'excludes folio, agenda_quarto, octavo, 32mo for horizontal chain lines' do
      formats = match_count(:horizontal).map(&:format).uniq
      expect(formats).to eq(%i(quarto sixteen_mo sixtyfour_mo))
    end

    it 'keeps only leaves at least as large as the measurement (inclusive)' do
      diagnoser.find_matches(48.0, 34.0, nil)
      expect(pairs(diagnoser.instance_variable_get(:@matches))).to eq([[:imperial, :folio]])
      diagnoser.find_matches(48.1, 34.0, nil)
      expect(diagnoser.instance_variable_get(:@matches)).to be_empty
    end

    context 'when $single' do
      before { $single = true }

      it 'adds full_sheet to the formats' do
        expect(match_count(nil).size).to eq(64)
      end

      # QUIRK: CHAIN_REVERSE[:chain] looks up the literal symbol :chain (nil),
      # so the rotated pass applies no chain-line exclusions at all.
      it 'QUIRK: rotated pass ignores chain direction' do
        expect(match_count(:vertical).size).to eq(64)
      end
    end

    # QUIRK: uniq! returns nil when nothing is removed; callers ignore it.
    it 'QUIRK: returns nil when there are no duplicates' do
      expect(diagnoser.find_matches(0, 0, nil)).to be_nil
    end
  end

  describe '#lock_format' do
    it 'restricts matches to one format regardless of chain' do
      diagnoser.lock_format(:folio)
      diagnoser.find_matches(0, 0, :horizontal)
      expect(diagnoser.instance_variable_get(:@matches).map(&:format).uniq).to eq([:folio])
    end

    it 'locks to full_sheet for single sheets, including the rotated pass' do
      $single = true
      diagnoser.lock_format(:full_sheet)
      diagnoser.find_matches(0, 0, :vertical)
      matches = diagnoser.instance_variable_get(:@matches)
      expect(matches.size).to eq(8)
      expect(matches.map(&:format).uniq).to eq([:full_sheet])
    end
  end

  describe '#sort_by_dim' do
    it 'sorts matches by area ascending' do
      diagnoser.find_matches(0, 0, nil)
      areas = diagnoser.sort_by_dim(:a).map(&:area)
      expect(areas).to eq(areas.sort)
      expect(diagnoser.sorted_matches).to eq(diagnoser.sort_by_dim(:a))
    end
  end

  describe '#get_results' do
    it 'returns [] when nothing matches' do
      expect(results(100, 100, nil, false, false)).to eq([])
    end

    it 'returns one result when only one matches' do
      expect(pairs(results(48.0, 34.0, nil, false, false))).to eq([[:imperial, :folio]])
    end

    it 'returns the two smallest with no deckles' do
      expect(pairs(results(0, 0, nil, false, false)))
        .to eq([[:half_median, :sixtyfour_mo], [:chancery, :sixtyfour_mo]])
    end

    it 'returns three when the categories form a CATEGORY_TRIOS entry' do
      expect(pairs(results(10.0, 24.5, nil, false, false)))
        .to eq([[:median, :folio], [:super_median, :folio], [:royal, :folio]])
    end

    it 'returns only the smallest with both deckles' do
      expect(pairs(results(0, 0, nil, true, true))).to eq([[:half_median, :sixtyfour_mo]])
    end

    it 'with a top/bottom deckle returns the smallest plus a tie in height' do
      expect(pairs(results(17.5, 0, nil, true, false)))
        .to eq([[:median, :octavo], [:half_median, :quarto]])
    end

    it 'with a side deckle returns the smallest by width' do
      expect(pairs(results(17.5, 0, nil, false, true))).to eq([[:half_median, :agenda_quarto]])
    end

    # QUIRK: returns a String, not a PaperSize; app.rb then calls
    # res.map(&:format) on it and raises NoMethodError (HTTP 500).
    it 'QUIRK: returns an "A or B" String when both deckles and equal areas' do
      res = results(17.5, 0, nil, true, true)
      expect(res).to eq(
        ['MEDIAN OCTAVO  [17.5cm x 12.5cm] or HALF-MEDIAN QUARTO  [17.5cm x 12.5cm]']
      )
      expect(res.first).to be_a(String)
    end
  end

  describe '#sheet_note' do
    it 'quarto: top deckle means half sheets' do
      expect(diagnoser.sheet_note(:quarto, true, false))
        .to eq(fmt: 'QUARTO', deck: 'top', sh: 'half sheets')
      expect(diagnoser.sheet_note(:quarto, false, true)).to be_nil
    end

    it 'octavo: top and bottom deckles mean quarter sheets' do
      expect(diagnoser.sheet_note(:octavo, true, true))
        .to eq(fmt: 'OCTAVO', deck: 'top and bottom', sh: 'quarter sheets')
      expect(diagnoser.sheet_note(:octavo, true, false)).to be_nil
    end

    it 'sixteen_mo: top and bottom deckles mean eighth sheets' do
      expect(diagnoser.sheet_note(:sixteen_mo, true, true))
        .to eq(fmt: '16mo', deck: 'top and bottom', sh: 'eighth sheets')
    end
  end
end
