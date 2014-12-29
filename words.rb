module Words
  module_function

  def path
    "/usr/share/dict/words"
  end

  def table
    @table ||= {}.tap {|t|
      File.read(path).split($/).each {|w| t[w] = true }
    }
  end

  def exists?(word)
    table[word]
  end
end
