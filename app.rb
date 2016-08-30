# If you're using bundler, you will need to add this
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler/setup'
require 'lib/paper_sizer'

require 'sinatra'

get '/' do
  erb :index
end

post '/sizeit' do
  height = params["paper_height"]
  width  = params["paper_width"]
  chain  = params["chain_lines"]
  deckle = params["deckle"]
  sizer = PaperSizer.new

  matches  = sizer.find_matches height, width
  if matches.length == 0
    result = "Those dimensions don't match any known paper size."
  elsif matches.length  == 1
    result = matches[0].ouput_name
  else
    matches_lines = sizer.query_lines chain
    if matches_lines.length == 1
      result = matches_lines[0].output_name
    else
      matches_edge = sizer.query_edge deckle
      if matches_edge.length ==1
        result = matches_edge[0].output_name
      else
        result = sizer.calculate_percent height, width
      end
    end
  end

  params["result"] = result
  erb :sizeit, locals: params
end