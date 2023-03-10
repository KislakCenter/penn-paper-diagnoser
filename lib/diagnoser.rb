require 'lib/paper_size'

class Diagnoser
  attr_reader :sorted_matches

  def initialize
    @formats    = %i(folio agenda_quarto quarto octavo sixteen_mo thirtytwo_mo sixtyfour_mo)
    @categories = %i(imperial super_royal royal super_median median super_chancery chancery half_median)
    @formats << :full_sheet if $single

    @papersizes = []
    @categories.each do |c|; @formats.each do |f|
      @papersizes << PaperSize.new(c,f)
    end; end

    @exclusion = Hash.new([])
    @exclusion[:vertical]   = %i(quarto sixteen_mo sixtyfour_mo full_sheet)
    @exclusion[:horizontal] = %i(folio agenda_quarto octavo thirtytwo_mo)
  end

  def lock_format(f)
    @exclusion = Hash.new(@formats - [f])
  end

# def find_matches(height, width, chain)
#   possible_formats = @formats - @exclusion[chain]
#   @matches = @papersizes.select do |ps|
#     possible_formats.include?(ps.format) && height <= ps.height && width <= ps.width
#   end
# end

  # ....................................................................
  CHAIN_REVERSE = {horizontal: :vertical, vertical: :horizontal}
  def find_matches(height, width, chain)
    @matches  = get_candidates(height, width, chain)
    @matches += get_candidates(width, height, CHAIN_REVERSE[:chain]) if $single
    @matches.uniq!
  end

  def get_candidates(height, width, chain)
     possible_fmts = @formats - @exclusion[chain]
   # possible_fmts = CHAIN_FORMATS[chain]
    @papersizes.select{ |f| possible_fmts.include?(f.format) && f.height >= height && f.width >= width }
  end
  # ....................................................................

  def sort_by_dim(dim)
    @sorted_matches = @matches.sort_by{ |m| m.measure(dim) }
  end

  def get_results(deckle_tobo, deckle_side)
    sm0 = @sorted_matches[0]
    sm1 = @sorted_matches[1]
    return []    if sm0.nil?
    return [sm0] if sm1.nil?
    if deckle_tobo && deckle_side
      equal_area = (sm1.area == sm0.area)
      equal_area ? ["#{sm0} or #{sm1}"] : [sm0]
    elsif deckle_tobo || deckle_side
      dim = deckle_tobo ? :h : :w
      sd  = sort_by_dim(dim)
      return [sd[0]] if sd[0].measure(dim) < sm0.measure(dim)
      second_place = sd.find{ |p| p != sm0 && p.measure(dim) == sm0.measure(dim) }
      second_place ? [sm0, second_place] : [sm0]
    else
      sm2 = @sorted_matches[2]
      return [sm0, sm1] if sm2.nil?
      super_exception = CATEGORY_TRIOS.include? [sm0, sm1, sm2].map(&:category)
      super_exception ? [sm0, sm1, sm2] : [sm0, sm1]
    end
  end

  CATEGORY_TRIOS = [
    %i(chancery super_chancery median),
    %i(median   super_median   royal),
    %i(royal    super_royal    imperial)
  ]


  def sheet_note(format, deckle_t, deckle_b)
    if format == :quarto
      deck      = 'top'
      condition = deckle_t
    else
      deck      = 'top and bottom'
      condition = deckle_t && deckle_b
    end
    sheet_size = case format
                 when :quarto     then 'half sheets'
                 when :octavo     then 'quarter sheets'
                 when :sixteen_mo then 'eighth sheets'
                 end
    condition ? {fmt: fmt_str(format), deck: deck, sh: sheet_size} : nil
  end
end

