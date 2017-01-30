def fmt_str(fmt)
  case fmt
  when :sixteen_mo
    "16mo"
  when :thirtytwo_mo
    "32mo"
  when :sixtyfour_mo
    "64mo"
  else
    fmt.to_s.upcase.sub('_' , '-')
  end
end


def cat_str(cat)
  cat.to_s.upcase.sub('_' , '-')
end

