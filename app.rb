$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler/setup'
require 'lib/diagnoser'

require 'sinatra'

get '/' do
  erb :index
end

post '/sizeit' do
  height      = params["paper_height"].to_f
  width       = params["paper_width"].to_f
  chain       = params["chain_lines"]
  $single     = params["object_type"] == 'single'
  $landsc     = $single && (width > height)

  deckles = []
  %w(top bo ri lef).each{ |d| deckles << (params[d] == 'checkd') }

  if $landsc # flip all parameters
    height, width = width, height
    chain = {'vertical' => 'horizontal', 'horizontal' => 'vertical'}[chain] # inelegant but relatively succint
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

  # OLD ############
  # deckle_tobo = params["deckle_tobo"] == 'top' #####
  # deckle_side = params["deckle_side"] == 'outer' ###
  # ###############

  d = Diagnoser.new
  d.lock_format(:full_sheet) if ! deckles.include?(false)
  # unless $landsc #################### not valid ###
  #   d.lock_format(:folio) if deckle_t && deckle_b
  # else
  #   d.lock_format(:folio) if deckle_l && deckle_r
  # end #############################################
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
    result = "The smallest available size is #{res[0]}. <br> The second smallest available size is #{res[1]}."
  when 3
    comp1  = %i(quarto sixteen_mo).include?(res[0].format) ? 'wider' : 'taller'
    comp2  = (comp1 == 'wider') ? 'taller' : 'wider' # {'wider' => 'taller', 'taller' => 'wider'}[comp1]
    comp1, comp2 = comp2, comp1 if $landsc
    result = "The smallest available size is #{res[0]}. #{res[1]} is #{comp1}. The more common #{res[2]} is both #{comp1} and #{comp2}." # no <br>eaks for the moment. This would look a lot better left-aligned.
  end                                                                                                                                    # Looks awkward broken and center-aligned # maybe not so bad

  q_only = false
  q_poss = false
  if deckle_t and ! $single
    res_forms = res.map(&:format)
    q_only = res_forms.uniq == [:quarto]
    q_poss = res_forms.include?(:quarto) unless q_only
  end
  res << "" if q_only # insert message
  res << "" if q_poss # insert message

  # result << "<br>RATIO: #{(height/width).round(2)}"
  larger  = (height >= width)  ? height : width
  smaller = (larger == height) ? width  : height
  ratio = "RATIO: #{larger/smaller} (reciprocal: #{smaller/larger})"

  params["result"] = result
  params["ratio"]  = ratio
  erb :sizeit, locals: params, layout: false
end




