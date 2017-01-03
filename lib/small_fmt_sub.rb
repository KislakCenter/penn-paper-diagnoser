class String
  def small_fmt_sub
  s = [
      %w(SIXTEEN-MO   16mo),
      %w(THIRTYTWO-MO 32mo),
      %w(SIXTYFOUR-MO 64mo)
      ].inject(self){ |o, p| o.sub(p[0], p[1]) }
  s
  end
end