module General_Utils
  class File_Utils
    def self.get_secure(line_num)
      line = IO.readlines(File.expand_path("../src/info/secure.txt", Dir.pwd))[line_num]
      return line
    end
  end
end
