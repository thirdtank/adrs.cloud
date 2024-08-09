class Actions::Adrs::TagSerializer
  def from_array(tags)
    tags.join(", ")
  end

  def from_string(tags_string)
    tags_string.to_s.split(/\n/).map { |line|
      line.split(/,/)
    }.flatten.map(&:strip).map(&:downcase).uniq
  end
end
