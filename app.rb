$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler/setup'
require 'lib/diagnoser'

require 'sinatra'

get '/' do
  erb :index
end

post '/sizeit' do
  height   = params["paper_height"].to_f
  width    = params["paper_width"].to_f
  chain    = params["chain_lines"]
  $single  = params["object_type"] == 'single'
  $landsc  = $single && width > height
  deckles  = %w(top bo ri lef).map{ |d| params[d] == 'checkd' }

  if $landsc # flip all parameters
    height, width = width, height
    chain = {'vertical' => 'horizontal', 'horizontal' => 'vertical'}[chain]
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
  d.lock_format(:full_sheet) if $landsc || ! deckles.include?(false)
  d.find_matches(height, width, chain)
  d.sort_by_dim(:a)

  result = ''
  res = d.get_results(deckle_tobo, deckle_side)
  case res.length
  when 0
    result = "No known paper sizes match your description."
  when 1
    result = "The only available size is #{res[0]}."
  when 2
    imp_vs_mm_format = res.map(&:name) == %i(imperial mezzo_median) ? res[0].format : nil
    result = "The smallest available size is #{res[0]}. <br> The second smallest available size is #{res[1]}."
  when 3
    comp1  = %i(quarto sixteen_mo).include?(res[0].format) ? 'wider' : 'taller'
    comp2  = (comp1 == 'wider') ? 'taller' : 'wider'
    comp1, comp2 = comp2, comp1 if $landsc
    result = "The smallest available size is #{res[0]}. #{res[1]} is #{comp1}. The more common #{res[2]} is both #{comp1} and #{comp2}."
  end

  if imp_vs_mm_format
    other_format = {octavo: :folio, sixteen_mo: :quarto}[imp_vs_mm_format]
    result << "<br>IMPERIAL and MEZZO-MEDIAN can be distinguished by the placement of the watermark." # If the watermark is ....
  end # ^^^ Wording ^^^^

  res_forms = res.map(&:format)
# sn = %i(quarto octavo sixteen_mo).select{ |f| res_forms.include?(f) }.map{ |f| sheet_note(f, deckle_t, deckle_b) }.reject(&:nil?)#.compact
  sn = %i(quarto octavo sixteen_mo).map{ |f| d.sheet_note(f, deckle_t, deckle_b) if res_forms.include?(f) }.compact
  note = case sn.length
  when 0
    ''
  when 1
    p1 = sn[0]
    if res.length == 1
      "<br>Since you found deckle on the #{p1[:deck]}, it's verly likely that it was written/printed on #{p1[:sh]}."
    else
      "<br>If it's #{p1[:fmt]}, since you found deckle on the #{p1[:deck]}, it's verly likely that it was written/printed on #{p1[:sh]}."
    end
  when 2
    p1 = sn[0]
    p2 = sn[1]
    "<br>Since you found deckle on the top and bottom, it's very likely that it was printed on #{p1[:sh]} if it's #{p1[:fmt]}, or on #{p2[:sh]} if it's #{p2[:fmt]}."
  end
  result << note

  larger, smaller = $landsc ? [width, height] : [height, width]
  ratio = "RATIO: #{(larger/smaller).round(2)} [reciprocal: #{(smaller/larger).round(2)}]"
  result << "<br>#{ratio}" unless height == 0 || width == 0 # # # # # # # # #

  params["result"] = result
  params["ratio"]  = ratio
  erb :sizeit, locals: params, layout: false
end




