
class PaperSize
  attr_reader :name
  attr_reader :format
  attr_reader :height
  attr_reader :width
  attr_reader :area

  UNTRIMDIMS = {
    imperial:       [49.0, 37.0],
    super_royal:    [45.0, 31.0],
    royal:          [43.0, 31.0],
    super_median:   [37.0, 25.5],
    median:         [35.0, 25.5],
    super_chancery: [34.0, 22.5],
    chancery:       [32.0, 22.5],
    mezzo_median:   [26.5, 19.5]
  }

  def initialize(name, format)
    @name   = name
    @format = format
    dims = get_dims(name, format)
    @height = dims[0].round(1)
    @width  = dims[1].round(1)
    @area   = (height * width).round(1)
  end

  def get_dims(name, format)
    utd = UNTRIMDIMS[name]
    convert(format, utd[0], utd[1])
  end

  def convert(format, h, w)
    case format
    when :folio         then [h,   w  ]
    when :agenda_quarto then [h,   w/2]
    when :quarto        then [w,   h/2]
    when :octavo        then [h/2, w/2]
    when :sixteen_mo    then [w/2, h/4]
    when :full_sheet    then [w*2, h  ]
    end
  end

  def measure(dim)
    case dim
    when :h
      height
    when :w
      width
    when :a
      area
    end
  end

  def == other
    return false unless other.is_a?(PaperSize)
    self.name == other.name && self.format == other.format
  end

  def to_s
    form = $single ? ALT_FORMAT[format] : format.upcase
    if $single
      ori = $landsc ? '(landscape) ' : '(portrait) '
    else
      ori = ''
    end
    "#{name.upcase} #{form} ".gsub('_' , '-').sub('SIXTEEN-MO' , '16mo') + "#{ori} #{dimensions}"
  end

  ALT_FORMAT = {
   full_sheet:    'full sheet',
   folio:         'half sheet',
   agenda_quarto: 'tall quarter sheet',
   quarto:        'quarter sheet',
   octavo:        'eighth sheet',
   sixteen_mo:    'sixteenth sheet'
  }

  def dimensions
    $landsc ? "[#{width}cm x #{height}cm]" : "[#{height}cm x #{width}cm]"
  end
end



