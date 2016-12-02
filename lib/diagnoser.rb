require 'lib/paper_size'

class Diagnoser
  attr_reader :sorted_matches

  def initialize
    @formats = %i(folio agenda_quarto quarto octavo sixteen_mo)
    @names   = %i(imperial super_royal royal super_median median super_chancery chancery mezzo_median)
    @formats += [:full_sheet] if $single

    @papersizes = []
    @formats.each do |f|
      @names.each do |n|
        @papersizes << PaperSize.new(f,n)
      end
    end

    @exclusion = Hash.new([])
    @exclusion['vertical']   = %i(quarto sixteen_mo)
    @exclusion['horizontal'] = %i(folio agenda_quarto octavo)
  end

  def find_matches(height, width, chain)
  possible_formats = @formats - @exclusion[chain]
  possible_matches = []
  @papersizes.each do |ps|
    if (possible_formats.include? ps.format) && (height <= ps.height) && (width <= ps.width)
      possible_matches << ps
    end
  end
    @matches = possible_matches
  end

  def sort_by_dim(dim)
    @sorted_matches = @matches.sort_by{ |m| m.measure(dim) }
  end

  def get_results(deckle_tobo, deckle_side)
    s0 = @sorted_matches[0]
    s1 = @sorted_matches[1]
    return [] if s0.nil?
    return [s0] if @sorted_matches.length == 1
    # return [s0] if $single # if sm[0].format == :full_sheet
    if (deckle_tobo && deckle_side)
      if s1.measure(:a) == s0.measure(:a)
        ["#{s0} or #{s1}"]
      else
        [s0]
      end
    elsif deckle_tobo || deckle_side
      dim = deckle_tobo ? :h : :w
      sd = sort_by_dim(dim)
      return [sd[0]] if sd[0].measure(dim) < s0.measure(dim)
      second = nil
      sd.each do |p|
        if p != s0 && (p.measure(dim) == s0.measure(dim))
          second = p
          break
        end
      end
      if second
        [s0, second]
      else
        [s0]
      end
    else
      [s0, s1]
    end
  end
end




