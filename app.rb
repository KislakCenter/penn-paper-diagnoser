$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'lib/diagnoser'
require 'sinatra'

#
require 'lib/small_fmt_sub'
#

get '/' do
  erb :index
end

post '/sizeit' do
  height   = params["paper_height"].to_f
  width    = params["paper_width"].to_f
  chainv   = params["chainlinesv"] == 'checkd'
  chainh   = params["chainlinesh"] == 'checkd'
  chain    = if chainv && chainh then :both
             elsif chainv        then :vertical
             elsif chainh        then :horizontal
             end
  $single  = params["object_type"] == 'single'
  $landsc  = $single && width > height
  deckles  = %w(top bottom right left).map{ |d| params[d] == 'checkd' }

  if $landsc # flip all parameters
    height, width = width, height
    chain = {vertical: :horizontal, horizontal: :vertical}[chain]
    deckles.reverse!
  end

  deckle_t, deckle_b, deckle_r, deckle_l = deckles
  if $single
    deckle_tobo = deckle_t && deckle_b
    deckle_side = deckle_r && deckle_l
  else
    deckle_tobo = deckle_t || deckle_b
    deckle_side = deckle_r || deckle_l
  end

  d = Diagnoser.new
  d.lock_format(:full_sheet) if $single && !deckles.include?(false)
  d.find_matches(height, width, chain)
  d.sort_by_dim(:a)

  res     = d.get_results(deckle_tobo, deckle_side)
  message =
    case res.length
    when 0
      "No known flavors match your description."
    when 1
      "The only available flavor is #{res[0]}."
    when 2
      imp_vs_hm_fmt = res.map(&:name) == %i(imperial half_median) ? res[1].format : nil
      "The smallest available flavor is #{res[0]}. "\
      "<br> The second smallest available flavor is #{res[1]}."
    when 3
      comp1  = %i(full_sheet quarto sixteen_mo sixtyfour_mo).include?(res[0].format) ? 'wider' : 'taller'
      comp2  = (comp1 == 'wider') ? 'taller' : 'wider'
      comp1, comp2 = comp2, comp1 if $landsc
      much   = (res[0].name == :chancery) ? '' : 'much'
      "The smallest available flavor is #{res[0]}. #{res[1]} is #{comp1}. "\
      "#{res[2]} is #{much} #{comp1} and #{comp2}."
    end

  imp_vs_hm_fmt ||= nil
  if imp_vs_hm_fmt && !$single
    water_loc =
      case imp_vs_hm_fmt
      when :octavo
        "traces of watermarks will be found at the top of the gutter. "
      when :sixteen_mo
         "traces of watermarks will be found at the top right corner."
      else
        loc = {folio: 'page', quarto: 'gutter'}[imp_vs_hm_fmt]
        "watermarks will appear in the center of the #{loc}."
      end
    message <<
    "<br>If it's HALF-MEDIAN #{fmt_str(imp_vs_hm_fmt)}, #{water_loc}"
  end



  unless $single
    res_fmts     = res.map(&:format)
    partial_fmts = %i(quarto octavo sixteen_mo).select{ |f| res_fmts.include?(f) }
    sn           = partial_fmts.map{ |f| d.sheet_note(f, deckle_t, deckle_b) }.compact
    note =
      case sn.length
      when 0
        ''
      when 1
        p1 = sn[0]
        if res.length == 1
          "<br>Deckle on the #{p1[:deck]} "\
          "indicates that it was written/printed on #{p1[:sh]}."
        else
          "<br>If it's #{p1[:fmt]}, deckle on the #{p1[:deck]} "\
          "indicates that it was written/printed on #{p1[:sh]}."
        end
      when 2
        p1 = sn[0]
        p2 = sn[1]
        "<br>Deckle on the top and bottom "\
        "indicates that it was written/printed on #{p1[:sh]} if it's #{p1[:fmt]}, "\
        "or on #{p2[:sh]} if it's #{p2[:fmt]}."
      end
    message << note
  end

  larger, smaller = $landsc ? [width, height] : [height, width] # is this contradictory with the new 'H/W' language?
  ratio = "H/W ratio: #{(larger/smaller).round(2)} [reciprocal: #{(smaller/larger).round(2)}]"
  message << "<br><br>#{ratio}" unless height == 0 || width == 0

  message = 'Please check either Vertical or Horizontal for the chain lines.' if chain == :both

  params["result"] = message
  params["ratio"]  = ratio
  erb :sizeit, locals: params, layout: false
end

