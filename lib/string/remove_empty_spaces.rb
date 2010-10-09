class String
  def remove_empty_spaces
    string = self.dup

    string.gsub!(/\A\W+/, '')
    string.gsub!(/\W+\Z/, '')

    string
  end
end
