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
  deckle_tobo = params["deckle_tobo"] == 'top'
  deckle_side = params["deckle_side"] == 'outer'
  $single     = params["object_type"] == 'single'
  $landsc     = $single && (width > height)
  if $landsc
    height, width = width, height
    chain = {'vertical' => 'horizontal', 'horizontal' => 'vertical'}[chain]
  end

  d = Diagnoser.new
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
    comp2  = {'wider' => 'taller', 'taller' => 'wider'}[comp1]
    result = "The smallest available size is #{res[0]}. #{res[1]} is #{comp1}; the more common #{res[2]} is both #{comp1} and #{comp2}." # no <br>eaks for the moment. This would look a lot better left-aligned. Looks awkward broken and center-aligned
  end

  # result << "<br>RATIO: #{(height/width).round(2)}"

  params["result"] = result
  erb :sizeit, locals: params, layout: false
end




