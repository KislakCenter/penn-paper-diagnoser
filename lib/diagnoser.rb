require 'lib/paper_size'

class Diagnoser
  attr_reader :height
  attr_reader :width
  attr_reader :chain
  attr_reader :matches

  def initialize (height, width, chain)
    @height = height
    @width  = width
    @chain  = chain

    @formats = %i(folio agenda_quarto quarto octavo sixteen_mo)
    @names   = %i(imperial super_royal royal super_median median super_chancery chancery mezzo_median)
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

  def find_matches
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
    key      = {}
    measures = []
    count = 1
    @matches.each do |mtc|
      msr = mtc.measure(dim)
      if key.include? msr
        msr -= 0.01 * count
        count += 1
      end
      key[msr] = mtc
      measures << msr
    end
    sorted = []
    measures.sort!.uniq!
    measures.each do |msr|
      sorted << key[msr]
    end
    @sorted_matches = sorted
    sorted
  end
end




