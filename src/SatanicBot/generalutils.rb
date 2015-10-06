module GeneralUtils
  class Files
    def self.get_secure(line_num)
      read = IO.readlines(File.expand_path('../../info/secure.txt', Dir.pwd))
      line = read[line_num]
      line
    end
  end
end
