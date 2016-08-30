class PaperType < Array
  def output_name
    name_string = (self[0].to_s + ' ' + self[1].to_s).upcase.gsub('_' , '-').sub('SIXTEEN-MO' , '16mo').sub((/MEDIAN-[12]/), 'MEDIAN')
    return name_string
  end
end



$paper_sizes =
  {
  PaperType.new([:folio, :imperial])       => {:height_max => 50.0, :height_min => 45.6, :width_max => 35.0, :width_min => 31.1},
  PaperType.new([:folio, :super_royal])    => {:height_max => 45.5, :height_min => 42.1, :width_max => 31.0, :width_min => 25.1},
  PaperType.new([:folio, :royal])          => {:height_max => 42.1, :height_min => 37.1, :width_max => 31.0, :width_min => 25.1},
  PaperType.new([:folio, :super_median])   => {:height_max => 37.0, :height_min => 35.1, :width_max => 25.0, :width_min => 22.1},
  PaperType.new([:folio, :median_1])       => {:height_max => 35.0, :height_min => 31.1, :width_max => 25.0, :width_min => 22.1},
  PaperType.new([:folio, :median_2])       => {:height_max => 31.0, :height_min => 28.0, :width_max => 25.0, :width_min => 22.6},
  PaperType.new([:folio, :super_chancery]) => {:height_max => 34.0, :height_min => 31.1, :width_max => 22.5, :width_min => 15.5},
  PaperType.new([:folio, :chancery])       => {:height_max => 31.0, :height_min => 25.5, :width_max => 22.5, :width_min => 15.5},
  PaperType.new([:folio, :mezzo_median])   => {:height_max => 25.6, :height_min => 24.0, :width_max => 19.0, :width_min => 15.5},
  PaperType.new([:agenda_quarto, :imperial])     => {:height_max => 50.0, :height_min => 45.6, :width_max => 20.0, :width_min => 15.0},
  PaperType.new([:agenda_quarto, :super_royal])  => {:height_max => 45.5, :height_min => 42.1, :width_max => 15.9, :width_min => 10.0},
  PaperType.new([:agenda_quarto, :royal])        => {:height_max => 42.0, :height_min => 37.1, :width_max => 15.9, :width_min => 10.0},
  PaperType.new([:agenda_quarto, :super_median]) => {:height_max => 37.0, :height_min => 35.1, :width_max => 12.5, :width_min =>  9.0},
  PaperType.new([:agenda_quarto, :median])       => {:height_max => 35.0, :height_min => 31.1, :width_max => 12.5, :width_min =>  9.0},
  PaperType.new([:agenda_quarto, :chancery])     => {:height_max => 31.0, :height_min => 25.5, :width_max => 11.3, :width_min =>  7.8},
  PaperType.new([:agenda_quarto, :mezzo_median]) => {:height_max => 25.6, :height_min => 24.0, :width_max => 9.5, :width_min =>   7.7},
  PaperType.new([:quarto, :super_royal])  => {:height_max => 31.0, :height_min => 25.1, :width_max => 22.7, :width_min => 21.0},
  PaperType.new([:quarto, :royal])        => {:height_max => 31.0, :height_min => 25.1, :width_max => 21.0, :width_min => 17.5},
  PaperType.new([:quarto, :super_median]) => {:height_max => 25.0, :height_min => 22.1, :width_max => 18.5, :width_min => 17.5},
  PaperType.new([:quarto, :median])       => {:height_max => 25.0, :height_min => 22.1, :width_max => 17.4, :width_min => 15.6},
  PaperType.new([:quarto, :chancery])     => {:height_max => 22.5, :height_min => 15.5, :width_max => 15.5, :width_min => 12.7},
  PaperType.new([:quarto, :mezzo_median]) => {:height_max => 19.0, :height_min => 15.5, :width_max => 12.6, :width_min => 12.0},
  PaperType.new([:octavo, :super_royal])   => {:height_max => 22.7, :height_min => 21.1, :width_max => 15.5, :width_min => 13.0},
  PaperType.new([:octavo, :royal])         => {:height_max => 21.0, :height_min => 17.5, :width_max => 15.5, :width_min => 12.6},
  PaperType.new([:octavo, :super_median])  => {:height_max => 18.5, :height_min => 17.7, :width_max => 12.5, :width_min => 11.1},
  PaperType.new([:octavo, :median])        => {:height_max => 17.4, :height_min => 15.6, :width_max => 12.5, :width_min => 11.1},
  PaperType.new([:octavo, :chancery])      => {:height_max => 15.5, :height_min => 12.7, :width_max => 11.2, :width_min =>  7.7},
  PaperType.new([:octavo, :mezzo_median])  => {:height_max => 12.8, :height_min => 12.0, :width_max => 9.5,  :width_min =>  7.7},
  PaperType.new([:sixteen_mo, :super_royal])  => {:height_max => 15.5, :height_min => 12.6, :width_max => 11.4, :width_min => 10.5},
  PaperType.new([:sixteen_mo, :royal])        => {:height_max => 15.5, :height_min => 12.6, :width_max => 10.4, :width_min =>  8.7},
  PaperType.new([:sixteen_mo, :super_median]) => {:height_max => 12.5, :height_min => 11.1, :width_max => 10.4, :width_min =>  8.7},
  PaperType.new([:sixteen_mo, :median])       => {:height_max => 12.5, :height_min => 11.1, :width_max => 8.7,  :width_min =>  7.8},
  PaperType.new([:sixteen_mo, :chancery])     => {:height_max => 11.3, :height_min => 7.7,  :width_max => 7.7,  :width_min =>  6.3},
  PaperType.new([:sixteen_mo, :mezzo_median]) => {:height_max => 9.5,  :height_min => 7.7,  :width_max => 6.3,  :width_min =>  6.0}
  }

  $possible_matches = [] #[PaperType.new(['ok', 'dok'])]

class PaperSizer
  def find_matches height, width
    matches = []
    $paper_sizes.each do |paper_size|
      paper_size[1][:height_range] = (paper_size[1][:height_min] .. paper_size[1][:height_max])
      paper_size[1][:width_range]  = (paper_size[1][:width_min] .. paper_size[1][:width_max])
      if paper_size[1][:height_range].include? height.to_f and paper_size[1][:width_range].include? width.to_f
        $possible_matches.push paper_size[0]
      end
    end
    return $possible_matches
  end

  def query_lines chain
  fold_groups = [[:folio, :agenda_quarto, :octavo] , [:quarto, :sixteen_mo ]]
    if chain.include? 'v'
      $possible_matches.each do |match|
        if fold_groups[1].include? match[0]
          $possible_matches -= [match]
        end
      end
    elsif chain.include? 'h'
      $possible_matches.each do |match|
        if fold_groups[0].include? match[0]
          $possible_matches -= [match]
        end
      end
    end
    return $possible_matches
  end

  def query_edge deckle
    deckle_meaning = {'yes' => :chancery, 'no' => :mezzo_median}
    $possible_matches.each do |match|
      if match[1] == deckle_meaning[deckle]
        $possible_matches -= [match]
      end
    end
    return $possible_matches
  end

  def calculate_percent height, width
    scores = {}
    score_sum = 0
    $possible_matches.each do |match|
      lower_height = $paper_sizes[match][:height_min] - 0.1
      upper_height = $paper_sizes[match][:height_max] + 0.1
      average_height = (upper_height + lower_height) / 2
      height_variation = average_height - lower_height
      height_difference = (average_height - height.to_f).abs
      height_score = (height_difference / height_variation) * 100

      lower_width = $paper_sizes[match][:width_min] - 0.1
      upper_width = $paper_sizes[match][:width_max] + 0.1
      average_width = (upper_width + lower_width) / 2
      width_variation = average_width - lower_width
      width_difference = (average_width - width.to_f).abs
      width_score = (width_difference / width_variation) * 100

      combined_score = (height_score + width_score) / 2

      scores[match] = combined_score
      score_sum += combined_score
    end
    percent_score = []
    $possible_matches.each do |match|
      final_score = scores[match] * (100 / score_sum)
      percent = final_score.round(2)
      percent_score.push percent
    end
    articles = []
    percent_score.each do |score|
      if [8, 11, 18, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89].include? score.to_i
        articles.push 'an'
      else
        articles.push 'a'
      end
    end
    return "There's about #{articles[0]} #{percent_score[0]}% chance that it's #{$possible_matches[0].output_name} and about #{articles[1]} #{percent_score[1]}% chance that it's #{$possible_matches[1].output_name}."
  end
end