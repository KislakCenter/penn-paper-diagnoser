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

  d = Diagnoser.new(height, width, chain)

  d.find_matches

  sm = d.sort_by_dim(:a)
  no_results = sm == []

  result = "No known paper sizes match your description."
  if no_results
    nil
  elsif deckle_tobo && deckle_side || sm.length == 1
    result = "The only available size is #{sm[0]}."
  elsif deckle_tobo || deckle_side
    dim = :h
    if deckle_side
      dim = :w
    end
    sd = d.sort_by_dim(dim)
    second = nil
    sd.each {|p| if p != sm[0] && (p.measure(dim) == sm[0].measure(dim)); second = p; break; end}
    if second
      result = "The smallest available size is #{sm[0]}. <br> The second smallest available size is #{second}."
    else
      result = "The only available size is #{sm[0]}."
    end
  else
    result = "The smallest available size is #{sm[0]}. <br> The second smallest available size is #{sm[1]}."
  end
  params["result"] = result
  erb :sizeit, locals: params, layout: false
end



