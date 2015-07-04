module General_Utils
  class File_Utils
    def self.get_secure(line_num)
      line = IO.readlines('../info/secure.txt')[line_num]
      return line
    end
  end
end
