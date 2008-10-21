class String
  def to_plain
    self.mb_chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/, '')
  end

  def to_slug
    self.to_plain.tr(' ', '-').downcase.gsub(/[^0-9a-z-]/, '')
  end
end